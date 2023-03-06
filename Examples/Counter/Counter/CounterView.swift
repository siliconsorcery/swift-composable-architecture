//
//  CounterView.swift
//  Counter
//
//  Created by John Cumming on 3/4/23.
//

import SwiftUI

struct CounterView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: CountView(state: state)
                    ,label: { Text("Count") }
                )
                NavigationLink(
                    destination: FavoritePrimesView(state: FavoritePrimesState(state: state))
                    ,label: { Text("Favorite Primes") }
                )
            }
            .navigationTitle("State Management")
        }
    }
}

struct CounterView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(state: AppState())
    }
}
