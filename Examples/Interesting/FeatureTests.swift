//
//  FeatureTests.swift
//  FeatureTests
//
//  Created by John Cumming on 3/6/23.
//

import ComposableArchitecture
import XCTest

@testable import Interesting

@MainActor
final class FeatureTests: XCTestCase {
    
    func testFeature() async {
        let store = TestStore(
            initialState: Feature.State()
            ,reducer: Feature()
        ) {
            $0.numberFact.fetch = { "\($0) is a good great number" }
            $0.continuousClock = ImmediateClock()
        }
        
        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }
        
        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }
        
        // Start timed increment of count ( 5 times )
        await store.send(.startTimerButtonTapped)
        
        await store.receive(.timerTick) {
          $0.count = 1
        }
        await store.receive(.timerTick) {
          $0.count = 2
        }
        await store.receive(.timerTick) {
          $0.count = 3
        }
        await store.receive(.timerTick) {
          $0.count = 4
        }
        await store.receive(.timerTick) {
          $0.count = 5
        }
        
        // Get number fact
        await store.send(.numberFactButtonTapped)
        
        await store.receive(.numberFactResponse(.success("5 is a good great number"))) {
            $0.numberFactAlert = "5 is a good great number"
        }
        
    }
    
}
