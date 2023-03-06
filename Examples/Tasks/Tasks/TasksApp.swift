//
//  TasksApp.swift
//  Tasks
//
//  Created by John Cumming on 3/4/23.
//

import ComposableArchitecture
import SwiftUI

@main
struct TasksApp: App {
    var body: some Scene {
        WindowGroup {
            TasksView(
                store: Store(
                    initialState: Tasks.State()
                    ,reducer: Tasks()._printChanges()
                )
            )
        }
    }
}
