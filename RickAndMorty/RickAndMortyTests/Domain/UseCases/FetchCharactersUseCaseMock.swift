//
//  FetchCharactersUseCaseMock.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 14/01/26.
//

import Foundation
@testable import RickAndMorty

@MainActor
final class FetchCharactersUseCaseMock: FetchCharactersUseCase {
    struct Invocation: Equatable {
        let page: Int
        let query: CharacterQuery
    }

    private(set) var invocations: [Invocation] = []
    private var results: [Result<CharacterPage, Error>]

    init(results: [Result<CharacterPage, Error>]) {
        self.results = results
    }

    func execute(page: Int, query: CharacterQuery) async throws -> CharacterPage {
        invocations.append(.init(page: page, query: query))
        guard !results.isEmpty else { throw APIClientError.invalidResponse }
        switch results.removeFirst() {
        case .success(let page):
            return page
        case .failure(let error):
            throw error
        }
    }
}

