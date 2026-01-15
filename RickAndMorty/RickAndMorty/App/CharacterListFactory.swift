//
//  CharacterListFactory.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 09/01/26.
//

import SwiftUI

enum CharacterListFactory {
    static func make() -> some View {
        let apiClient = DefaultAPIClient()
        let repository = RemoteCharacterRepository(client: apiClient)
        let useCase = DefaultFetchCharactersUseCase(repository: repository)
        let viewModel = CharacterListViewModel(fetchCharactersUseCase: useCase)
        return CharacterListView(viewModel: viewModel)
    }
}
