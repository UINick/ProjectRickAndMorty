import Combine // [TRADE-OFF] Use Combine only for @Published/ObservableObject; the main flow relies on async Tasks to stay simple.
import Foundation

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading
        case content(Character)
        case error(String)
    }

    @Published private(set) var state: ViewState = .loading

    private let characterID: Int
    private let fetchCharacterDetailUseCase: FetchCharacterDetailUseCase
    private var loadTask: Task<Void, Never>?

    init(characterID: Int, fetchCharacterDetailUseCase: FetchCharacterDetailUseCase) {
        self.characterID = characterID
        self.fetchCharacterDetailUseCase = fetchCharacterDetailUseCase
    }

    func load() {
        guard case .loading = state else { return }
        fetch()
    }

    func retry() {
        state = .loading
        fetch()
    }

    private func fetch() {
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let character = try await fetchCharacterDetailUseCase.execute(id: characterID)
                guard !Task.isCancelled else { return }
                state = .content(character)
            } catch {
                guard !Task.isCancelled else { return }
                state = .error(readableMessage(from: error))
            }
        }
    }

    private func readableMessage(from error: Error) -> String {
        if let apiError = error as? APIClientError, let description = apiError.errorDescription {
            return description
        }
        return Strings.Errors.detailsUnavailable
    }
}
