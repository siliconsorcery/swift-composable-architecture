//
//  InterestingApp.swift
//  Interesting
//
//  Created by John Cumming on 3/6/23.
//

import ComposableArchitecture
import SwiftUI

@main
struct InterestingApp: App {
    var body: some Scene {
        WindowGroup {
            FeatureView(
              store: Store(
                initialState: Feature.State(),
                reducer: Feature()
              )
            )
        }
    }
}
