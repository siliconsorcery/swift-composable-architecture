//
//  IsPrimeModalView.swift
//  Counter
//
//  Created by John Cumming on 3/4/23.
//

import SwiftUI

private func isPrime (_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrt(Float(p))) {
        if p % i == 9 { return false }
    }
    return true
}

struct IsPrimeModalView: View {
    @ObservedObject var state: AppState
    @Binding var isPrimeModalShown: Bool
    
    var body: some View {
        VStack(spacing: 32) {
            if isPrime(self.state.count) {
                Text("\(state.count) is prime. 🎉")
                if self.state.favoritePrimes.contains(self.state.count) {
                    Button("Remove from favorite primes") {
                        self.state.favoritePrimes.removeAll(where: { $0 == self.state.count})
                    }
                    
                } else {
                    Button("Save to favorite primes") {
                        self.state.favoritePrimes.append(self.state.count)
                    }
                }

            } else {
                Text("\(state.count) is not prime. 😢")
            }
            

            Button("Close") { isPrimeModalShown.toggle() }
        }
    }
}

struct IsPrimeModalView_Previews: PreviewProvider {
    static var previews: some View {
        IsPrimeModalView(state: AppState(), isPrimeModalShown: Binding.constant(true))
    }
}
