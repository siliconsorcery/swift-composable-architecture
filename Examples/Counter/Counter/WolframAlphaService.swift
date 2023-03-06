//
//  WolframAlphaService.swift
//  Counter
//
//  Created by John Cumming on 3/4/23.
//

import Foundation

struct WolframAlphaResult: Decodable {
    let queryResult: QueryResult
    
    struct QueryResult: Decodable {
        let pods: [Pod]
        
        struct Pod: Decodable {
            let primary: Bool?
            let subpods: [SubPod]
            
            struct SubPod: Decodable {
                let plainText: String
            }
        }
    }
}

func wolframAlpha(query: String, callback: @escaping (WolframAlphaResult?) -> Void) -> Void {
    var components = URLComponents(string: "https://api.wolframalpha.com/v2/query/")!
    components.queryItems = [
        URLQueryItem(name: "input", value: query)
        ,URLQueryItem(name: "format", value: "plainText")
        ,URLQueryItem(name: "output", value: "JSON")
        ,URLQueryItem(name: "appid", value: wolframAlphaAPIKey)
    ]
    
    URLSession.shared.dataTask(
        with: components.url(relativeTo: nil)!
        ,completionHandler: { data, response, error in
            callback(
                data.flatMap { try? JSONDecoder().decode(WolframAlphaResult.self, from: $0) }
            )
        }
    )
    .resume()
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
    wolframAlpha(
        query: "prime \(n)"
        ,callback: { result in
            callback(
                result
                    .flatMap {
                        $0.queryResult
                            .pods
                            .first(where: { $0.primary == .some(true) })?
                            .subpods
                            .first?
                            .plainText
                    }
                    .flatMap(Int.init)
            )
        }
    )
}
