//
//  FavoritePrimesView.swift
//  FavoritePrimes
//
//  Created by John Cumming on 3/4/23.
//

import SwiftUI

class FavoritePrimesState: ObservableObject {
    private var state: AppState
    
    init(state: AppState) {
        self.state = state
    }
    
    var favoritePrimes: [Int] {
        get { self.state.favoritePrimes }
        set { self.state.favoritePrimes = newValue }
    }
    
    var activityFeed: [AppState.Activity] {
        get { self.state.activityFeed }
        set { self.state.activityFeed = newValue }
    }
}

struct FavoritePrimesView: View {
    @ObservedObject var state: FavoritePrimesState

    var body: some View {
        
        List {
            ForEach(state.favoritePrimes, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete(
                perform: { indexSet in
                    for index in indexSet {
                        state.favoritePrimes.remove(at: index)
                    }
                }
            )
        }
        .navigationBarTitle(
            Text("Favorite Primes")
        )
    }
}

struct FavoritePrimesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritePrimesView(state: FavoritePrimesState(state: AppState()))
    }
}
