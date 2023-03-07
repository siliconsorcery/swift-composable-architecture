//
//  NumberFactClient.swift
//  Interesting
//
//  Created by John Cumming on 3/6/23.
//

import ComposableArchitecture
import SwiftUI

struct NumberFactClient {
    var fetch: (Int) async throws -> String
}

extension NumberFactClient: DependencyKey {
    static let liveValue = NumberFactClient(
        fetch: { number in
            let session = URLSession.shared
            let (data, _) = try await session.data(
                from: .init(string: "http://numbersapi.com/\(number)")!
            )
            return String(decoding: data, as: UTF8.self)
        }
    )
}

extension DependencyValues {
  var numberFact: NumberFactClient {
    get { self[NumberFactClient.self] }
    set { self[NumberFactClient.self] = newValue }
  }
}
