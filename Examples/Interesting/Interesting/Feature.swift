//
//  Feature.swift
//  Interesting
//
//  Created by John Cumming on 3/6/23.
//

import ComposableArchitecture
import SwiftUI

struct Feature: ReducerProtocol {
    struct State: Equatable {
        var count = 0
        var numberFactAlert: String?
    }
    
    enum Action: Equatable {
        case factAlertDismissed
        case decrementButtonTapped
        case incrementButtonTapped
        case numberFactButtonTapped
        case numberFactResponse(TaskResult<String>)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
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
                        String(
                            decoding: try await URLSession
                                .shared
                                .data(from: URL(string: "http://numbersapi.com/\(count)/trivia")!)
                                .0
                            ,as: UTF8.self
                        )
                    }
                )
            }
            
        case let .numberFactResponse(.success(fact)):
            state.numberFactAlert = fact
            return .none
            
        case .numberFactResponse(.failure):
            state.numberFactAlert = "Could not load a number fact :("
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
