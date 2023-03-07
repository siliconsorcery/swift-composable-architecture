//
//  CounterApp.swift
//  Counter
//
//  Created by John Cumming on 3/4/23.
//

import SwiftUI

@main
struct CounterApp: App {
    var body: some Scene {
        WindowGroup {
            CounterView(state: AppState())
        }
    }
}

class AppState: ObservableObject {
    @Published var count = 0
    @Published var favoritePrimes: [Int] = []
    @Published var loggedInUser: User?
    @Published var activityFeed: [Activity] = []
    
    struct Activity {
        let timestamp: Date
        let type: ActivityType
        
        enum ActivityType {
            case addedFavoriatePrime(Int)
            case removedFavorites(Int)
        }
    }
    
    struct User {
        let id: UUID
        let name: String
        let bio: String
    }
}

