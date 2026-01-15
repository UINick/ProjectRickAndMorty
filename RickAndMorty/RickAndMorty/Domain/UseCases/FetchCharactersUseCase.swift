//
//  FetchCharactersUseCase.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 10/01/26.
//

import Foundation

protocol FetchCharactersUseCase {
    func execute(page: Int, query: CharacterQuery) async throws -> CharacterPage
}

struct DefaultFetchCharactersUseCase: FetchCharactersUseCase {
    private let repository: CharacterRepository

    init(repository: CharacterRepository) {
        self.repository = repository
    }

    func execute(page: Int, query: CharacterQuery) async throws -> CharacterPage {
        try await repository.fetchCharacters(page: page, query: query)
    }
}
