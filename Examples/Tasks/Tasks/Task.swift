//
//  Task.swift
//  Tasks
//
//  Created by John Cumming on 3/4/23.
//

import ComposableArchitecture
import SwiftUI

struct Task: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID
        var text = ""
        var isComplete = false
    }
    
    enum Action: Equatable {
        case checkBoxToggled
        case textFieldChanged(String)
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .checkBoxToggled:
            state.isComplete.toggle()
            return .none
            
        case let .textFieldChanged(text):
            state.text = text
            return .none
        }
    }
}

struct TaskView: View {
    let store: StoreOf<Task>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            HStack {
                Button(action: { viewStore.send(.checkBoxToggled) }) {
                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(.plain)
                
                TextField(
                    "New Task"
                    ,text: viewStore.binding(
                        get: \.text,
                        send: Task.Action.textFieldChanged
                    )
                )
            }
            .foregroundColor(viewStore.isComplete ? .gray : nil)
        }
    }
}
