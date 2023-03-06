//
//  CountView.swift
//  Counter
//
//  Created by John Cumming on 3/4/23.
//

import SwiftUI

struct CountView: View {
    @ObservedObject var state: AppState
    @State var isPrimeModalShown = false
    @State var isNthPrimeShown = false
    @State var alertNthPrime: Int?
    @State var isNthPrimeButtonDisabled = false
        
    private func ordinal(_ n: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter.string(from: n as NSNumber) ?? ""
    }
    
    var body: some View {
        
        VStack(spacing: 24) {
            HStack {
                Button(
                    action: { self.state.count -= 1 }
                    ,label: { Text("-") }
                )
                
                Text("\(self.state.count)")
                
                Button(
                    action: { self.state.count += 1 }
                    ,label: { Text("+") }
                )
            }
            
            Button(
                action: { self.isPrimeModalShown.toggle() }
                ,label: { Text("Is this Prime?") }
            )
            
            Button(
                action: {
                    self.isNthPrimeButtonDisabled = true
                    nthPrime(
                        state.count
                        ,callback: { prime in
                            if prime != nil {
                                alertNthPrime = prime
                                isNthPrimeShown.toggle()
                            }
                            self.isNthPrimeButtonDisabled = false
                        }
                    )
                }
                ,label: { Text("What is the \(ordinal(self.state.count)) prime?") }
            )
            .disabled(self.isNthPrimeButtonDisabled)
        }
        .font(.title)
        .navigationTitle("Count")
        .sheet(
            isPresented: $isPrimeModalShown
            ,content: { IsPrimeModalView(state: state, isPrimeModalShown: $isPrimeModalShown) }
        )
        .alert(
            "\(ordinal(state.count)) prime is \(alertNthPrime ?? 42)"
            ,isPresented: $isNthPrimeShown
            ,actions: {
                Button(
                    "OK"
                    ,role: .cancel
                    ,action: { isNthPrimeShown.toggle() }
                )
            }
        )
    }
}

struct CountView_Previews: PreviewProvider {
    static var previews: some View {
        CountView(state: AppState())
    }
}
