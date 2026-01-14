import SwiftUI

enum CharacterDetailFactory {
    static func make(characterID: Int) -> some View {
        // [TRADE-OFF] Recreate the chain (client→repo→use case) for screen independence; extra object cost is acceptable for clarity and isolation.
        let apiClient = DefaultAPIClient()
        let repository = RemoteCharacterRepository(client: apiClient)
        let useCase = DefaultFetchCharacterDetailUseCase(repository: repository)
        let viewModel = CharacterDetailViewModel(characterID: characterID, fetchCharacterDetailUseCase: useCase)
        return CharacterDetailView(viewModel: viewModel)
    }
}
