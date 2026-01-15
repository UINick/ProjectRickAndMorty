//
//  FetchCharacterDetailUseCase.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 10/01/26.
//

import Foundation

protocol FetchCharacterDetailUseCase {
    func execute(id: Int) async throws -> Character
}

struct DefaultFetchCharacterDetailUseCase: FetchCharacterDetailUseCase {
    private let repository: CharacterRepository

    init(repository: CharacterRepository) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> Character {
        try await repository.fetchCharacter(id: id)
    }
}
