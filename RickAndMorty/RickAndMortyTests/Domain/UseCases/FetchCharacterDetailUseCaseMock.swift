//
//  FetchCharacterDetailUseCaseMock.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 14/01/26.
//

import Foundation
@testable import RickAndMorty

@MainActor
final class FetchCharacterDetailUseCaseMock: FetchCharacterDetailUseCase {
    private(set) var invocations: [Int] = []
    private var results: [Result<Character, Error>]

    init(results: [Result<Character, Error>]) {
        self.results = results
    }

    func execute(id: Int) async throws -> Character {
        invocations.append(id)
        guard !results.isEmpty else { throw APIClientError.invalidResponse }
        switch results.removeFirst() {
        case .success(let character):
            return character
        case .failure(let error):
            throw error
        }
    }
}

