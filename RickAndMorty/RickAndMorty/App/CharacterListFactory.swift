import SwiftUI

enum CharacterListFactory {
    static func make() -> some View {
        // [TRADE-OFF] Optamos por factories simples em vez de um contêiner de DI/global para manter o wiring explícito e local, mesmo recriando dependências ao abrir a tela.
        let apiClient = DefaultAPIClient()
        let repository = RemoteCharacterRepository(client: apiClient)
        let useCase = DefaultFetchCharactersUseCase(repository: repository)
        let viewModel = CharacterListViewModel(fetchCharactersUseCase: useCase)
        return CharacterListView(viewModel: viewModel)
    }
}
