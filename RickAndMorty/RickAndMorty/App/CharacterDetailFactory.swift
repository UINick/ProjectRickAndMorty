//
//  CharacterDetailFactory.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 09/01/26.
//

import SwiftUI

enum CharacterDetailFactory {
    static func make(characterID: Int) -> some View {
        let apiClient = DefaultAPIClient()
        let repository = RemoteCharacterRepository(client: apiClient)
        let useCase = DefaultFetchCharacterDetailUseCase(repository: repository)
        let viewModel = CharacterDetailViewModel(characterID: characterID, fetchCharacterDetailUseCase: useCase)
        return CharacterDetailView(viewModel: viewModel)
    }
}
