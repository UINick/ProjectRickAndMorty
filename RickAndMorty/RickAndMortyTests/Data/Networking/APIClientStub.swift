//
//  APIClientStub.swift
//  RickAndMortyTests
//
//  Created by Nicholas Forte on 14/01/26.
//

import Foundation
@testable import RickAndMorty

final class APIClientStub: APIClient {
    struct Request {
        let path: String
        let queryItems: [URLQueryItem]
    }

    private(set) var requests: [Request] = []
    private let responses: [String: Result<Data, Error>]

    init(responses: [String: Result<Data, Error>]) {
        self.responses = responses
    }

    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]) async throws -> T {
        requests.append(.init(path: path, queryItems: queryItems))
        guard let result = responses[path] else { throw APIClientError.invalidURL }

        switch result {
        case .success(let data):
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIClientError.decoding(error)
            }
        case .failure(let error):
            throw error
        }
    }
}
