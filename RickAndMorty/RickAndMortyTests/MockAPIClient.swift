//
//  RickAndMortyApp.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 13/01/26.
//

import Foundation
@testable import RickAndMorty

final class MockAPIClient: APIClient {
    enum MockError: Error {
        case unexpectedPath
        case decodeFailed
    }

    func get<T>(_ path: String, queryItems: [URLQueryItem]) async throws -> T where T : Decodable {
        // [TRADE-OFF] Simple mock keyed by request path; covers the character detail case for UI/ViewModel tests.
        if path == "character/299" {
            let data = Data(Self.character299JSON.utf8)
            let decoder = JSONDecoder()
            guard let decoded = try? decoder.decode(T.self, from: data) else {
                throw MockError.decodeFailed
            }
            return decoded
        }
        throw MockError.unexpectedPath
    }
}

extension MockAPIClient {
    static let character299JSON = """
    {
      "id" : 299,
      "gender" : "Male",
      "url" : "https://rickandmortyapi.com/api/character/299",
      "type" : "",
      "species" : "Robot",
      "episode" : [
        "https://rickandmortyapi.com/api/episode/10"
      ],
      "location" : {
        "name" : "Citadel of Ricks",
        "url" : "https://rickandmortyapi.com/api/location/3"
      },
      "image" : "https://rickandmortyapi.com/api/character/avatar/299.jpeg",
      "origin" : {
        "name" : "unknown",
        "url" : ""
      },
      "created" : "2017-12-31T20:38:17.990Z",
      "name" : "Robot Rick",
      "status" : "unknown"
    }
    """
}
