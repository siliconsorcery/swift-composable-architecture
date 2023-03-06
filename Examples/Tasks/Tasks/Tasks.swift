//
//  Tasks.swift
//  Tasks
//
//  Created by John Cumming on 3/4/23.
//

import ComposableArchitecture
import SwiftUI

struct Tasks: ReducerProtocol {
    struct State: Equatable {
        var editMode: EditMode = .inactive
        var filter: Filter = .all
        var tasks: IdentifiedArrayOf<Task.State> = []
        
        var filtered: IdentifiedArrayOf<Task.State> {
            switch filter {
            case .active: return self.tasks.filter { !$0.isComplete }
            case .all: return self.tasks
            case .completed: return self.tasks.filter(\.isComplete)
            }
        }
    }
    
    enum Action: Equatable {
        case addTaskButtonTapped
        case clearCompletedButtonTapped
        case delete(IndexSet)
        case editModeChanged(EditMode)
        case filterPicked(Filter)
        case filterForAdd
        case move(IndexSet, Int)
        case sortCompletedTasks
    
        case task(id: Task.State.ID, action: Task.Action)
    }
    
    @Dependency(\.continuousClock) var clock
    @Dependency(\.uuid) var uuid
    private enum TaskCompletionID {}
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .addTaskButtonTapped:
                state.tasks.insert(Task.State(id: self.uuid()), at: 0)
                return .task {
                    return .filterForAdd
                }
                
            case .clearCompletedButtonTapped:
                state.tasks.removeAll(where: \.isComplete)
                return .none
                
            case let .delete(indexSet):
                let filteredTasks = state.filtered
                for index in indexSet {
                    state.tasks.remove(id: filteredTasks[index].id)
                }
                return .none
                
            case let .editModeChanged(editMode):
                state.editMode = editMode
                return .none
                
            case let .filterPicked(filter):
                state.filter = filter
                return .none
                
            case .filterForAdd:
                if state.filter == .completed {
                    state.filter = .all
                }
                return .none
                
            case var .move(source, destination):
                if state.filter == .completed {
                    source = IndexSet(
                        source
                            .map { state.filtered[$0] }
                            .compactMap { state.tasks.index(id: $0.id) }
                    )
                    destination = (
                        destination < state.filtered.endIndex
                        ? state.tasks.index(id: state.filtered[destination].id)
                        : state.tasks.endIndex
                    ) ?? destination
                }
                state.tasks.move(fromOffsets: source, toOffset: destination)
                return .task {
                    try await self.clock.sleep(for: .milliseconds(100))
                    return .sortCompletedTasks
                }
                
            case .sortCompletedTasks:
                state.tasks.sort { $1.isComplete && !$0.isComplete }
                return .none
                
            case .task(id: _, action: .checkBoxToggled):
              return .run { send in
                try await self.clock.sleep(for: .seconds(1))
                await send(.sortCompletedTasks, animation: .default)
              }
              .cancellable(id: TaskCompletionID.self, cancelInFlight: true)

            case .task:
              return .none
            }
        }
        .forEach(\.tasks, action: /Action.task(id:action:)) {
            Task()
        }
    }
    
    enum Filter: LocalizedStringKey, CaseIterable, Hashable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
    }
}

struct TasksView: View {
    let store: StoreOf<Tasks>
    @ObservedObject var viewStore: ViewStore<ViewState, Tasks.Action>
    
    
    init(store: StoreOf<Tasks>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: ViewState.init(state:)))
    }
    
    struct ViewState: Equatable {
        let editMode: EditMode
        let filter: Tasks.Filter
        let isClearCompletedButtonDisabled: Bool
        
        init(state: Tasks.State) {
            self.editMode = state.editMode
            self.filter = state.filter
            self.isClearCompletedButtonDisabled = !state.tasks.contains(where: \.isComplete)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker(
                    "Filter"
                    ,selection: self.viewStore.binding(
                        get: \.filter
                        ,send: Tasks.Action.filterPicked
                    )
                    .animation()
                ) {
                    ForEach(Tasks.Filter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                List {
                    ForEachStore(
                        self.store.scope(
                            state: \.filtered
                            ,action: Tasks.Action.task(id:action:)
                        )
                    ) {
                        TaskView(store: $0)
                    }
                    .onDelete { self.viewStore.send(.delete($0)) }
                    .onMove { self.viewStore.send(.move($0, $1)) }
                }
            }
            .navigationTitle("Tasks")
            .navigationBarItems(
                trailing: HStack(spacing: 16) {
                    EditButton()

                    Button(
                        action: {
                            self.viewStore.send(.clearCompletedButtonTapped, animation: .default)
                        }, label: {
                            Image(systemName: "clear")
                                .imageScale(.large)
                                .foregroundColor(.accentColor)
                        }
                    )
                    .disabled(self.viewStore.isClearCompletedButtonDisabled)
                                        
                    Button(
                        action: {
                            self.viewStore.send(.addTaskButtonTapped, animation: .default)
                        }, label: {
                            Image(systemName: "plus.circle")
                                .imageScale(.large)
                                .foregroundColor(.accentColor)
                        }
                    )
                }
            )
            .environment(
                \.editMode
                 ,self.viewStore.binding(
                    get: \.editMode
                    ,send: Tasks.Action.editModeChanged
                 )
            )
        }
        .navigationViewStyle(.stack)
    }
}

extension IdentifiedArray where ID == Task.State.ID, Element == Task.State {
    static let mock: Self = [
        Task.State(
            id: UUID(uuidString: "11112222-1111-1111-1111-111122223300")!
            ,text: "Check Mail"
            ,isComplete: false
        ),
        Task.State(
            id: UUID(uuidString: "11112222-1111-1111-1111-111122223301")!
            ,text: "Buy Milk"
            ,isComplete: false
        ),
        Task.State(
            id: UUID(uuidString: "11112222-1111-1111-1111-111122223302")!
            ,text: "Call Home"
            ,isComplete: true
        ),
    ]
}

struct TasksView_Previews: PreviewProvider {
    static var previews: some View {
        TasksView(
            store: Store(
                initialState: Tasks.State(tasks: .mock)
                ,reducer: Tasks()
            )
        )
    }
}
