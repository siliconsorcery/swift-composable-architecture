//
//  Feature.swift
//  Interesting
//
//  Created by John Cumming on 3/6/23.
//

import Clocks
import ComposableArchitecture
import SwiftUI

struct Feature: ReducerProtocol {
    @Dependency(\.numberFact) var numberFact
    @Dependency(\.continuousClock) var clock

    struct State: Equatable {
        var count = 0
        var numberFactAlert: String?
    }
    
    enum Action: Equatable { case
        factAlertDismissed
        ,decrementButtonTapped
        ,incrementButtonTapped
        ,numberFactButtonTapped
        ,numberFactResponse(TaskResult<String>)
        ,startTimerButtonTapped
        ,timerTick
    }
    
    
    func reduce(
        into state: inout State
        ,action: Action
    ) -> EffectTask<Action> {
    
        switch action {
        case .factAlertDismissed:
            state.numberFactAlert = nil
            return .none
            
        case .decrementButtonTapped:
            state.count -= 1
            return .none
            
        case .incrementButtonTapped:
            state.count += 1
            return .none
            
        case .numberFactButtonTapped:
            return .task { [count = state.count] in
                await .numberFactResponse(
                    TaskResult {
                        try await self.numberFact.fetch(count)
                    }
                )
            }
            
        case let .numberFactResponse(.success(fact)):
            state.numberFactAlert = fact
            return .none
            
        case .numberFactResponse(.failure):
            state.numberFactAlert = "Could not load a number fact!"
            return .none
            
        case .startTimerButtonTapped:
            return .run { send in
                for _ in 1...5 {
                    try await self.clock.sleep(for: .seconds(1))
                    await send(.timerTick)
                }
            }
            
        case .timerTick:
            state.count += 1
            return .none
        }
    }
}

struct FeatureView: View {
    let store: StoreOf<Feature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 24) {
                HStack {
                    Button("−") {
                        viewStore.send(.decrementButtonTapped)
                    }
                    
                    Text("\(viewStore.count)")
                    
                    Button("+") {
                        viewStore.send(.incrementButtonTapped)
                    }
                }
                
                Button("Get Number Fact") {
                    viewStore.send(.numberFactButtonTapped)
                }

                Button("Slowing Add 5") {
                    viewStore.send(.startTimerButtonTapped)
                }

            }
            .font(.title)
            .alert(
                item: viewStore.binding(
                    get: { $0.numberFactAlert.map(FactAlert.init(title:)) },
                    send: .factAlertDismissed
                ),
                content: {
                    Alert(title: Text($0.title))
                }
            )
        }
    }
}

struct FactAlert: Identifiable {
    var title: String
    var id: String { self.title }
}
