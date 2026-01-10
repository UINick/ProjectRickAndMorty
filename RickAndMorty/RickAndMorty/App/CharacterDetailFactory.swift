import SwiftUI

enum CharacterDetailFactory {
    static func make(characterID: Int) -> some View {
        // [TRADE-OFF] Recriamos a cadeia (client→repo→use case) para independência entre telas; custo de objetos extra é aceitável pela clareza e isolamento.
        let apiClient = DefaultAPIClient()
        let repository = RemoteCharacterRepository(client: apiClient)
        let useCase = DefaultFetchCharacterDetailUseCase(repository: repository)
        let viewModel = CharacterDetailViewModel(characterID: characterID, fetchCharacterDetailUseCase: useCase)
        return CharacterDetailView(viewModel: viewModel)
    }
}
