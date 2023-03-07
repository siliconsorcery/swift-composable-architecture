//
//  TasksTests.swift
//  Tasks
//
//  Created by John Cumming on 3/4/23.
//

import ComposableArchitecture
import XCTest

@testable import Tasks

@MainActor
final class TasksTests: XCTestCase {
    let clock = TestClock()
    
    func testAddTodo() async {
        let store = TestStore(
            initialState: Tasks.State()
            ,reducer: Tasks()
        ) {
            $0.uuid = .incrementing
        }
        
        await store.send(.addTaskButtonTapped) {
            $0.tasks.insert(
                Task.State(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
                    ,text: ""
                    ,isComplete: false
                )
                ,at: 0
            )
        }
        
//        await store.receive(.filterForAdd) {_ in }
        await store.send(.addTaskButtonTapped) {
            $0.tasks = [
                Task.State(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
                    ,text: ""
                    ,isComplete: false
                )
                ,Task.State(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
                    ,text: ""
                    ,isComplete: false
                )
            ]
        }
    }
    
    func testEditTask() async {
        let state = Tasks.State(
            tasks: [
                Task.State(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
                    ,text: "Fix what bugs you"
                    ,isComplete: false
                )
                ,Task.State(
                    id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
                    ,text: "Watch for bad weather"
                    ,isComplete: false
                )

            ]
        )
        
        let store = TestStore(
            initialState: state
            ,reducer: Tasks()
        ) {
            $0.continuousClock = self.clock
        }
        
        await store.send(.task(id: state.tasks[0].id, action: .checkBoxToggled)) {
            $0.tasks[id: state.tasks[0].id]?.isComplete = true
        }
        
        await self.clock.advance(by: .seconds(1))
        
        await store.receive(.sortCompletedTasks) {
            $0.tasks = [
                $0.tasks[1]
                ,$0.tasks[0]
            ]
        }        
    }
}

