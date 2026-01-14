import SwiftUI

enum CharacterListFactory {
    static func make() -> some View {
        // [TRADE-OFF] Chose simple factories instead of a global DI container to keep wiring explicit and local, even if dependencies are recreated when opening the screen.
        let apiClient = DefaultAPIClient()
        let repository = RemoteCharacterRepository(client: apiClient)
        let useCase = DefaultFetchCharactersUseCase(repository: repository)
        let viewModel = CharacterListViewModel(fetchCharactersUseCase: useCase)
        return CharacterListView(viewModel: viewModel)
    }
}
