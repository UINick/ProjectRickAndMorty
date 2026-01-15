//
//  CharacterListViewModel.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 09/01/26.
//

import Combine
import Foundation

@MainActor
final class CharacterListViewModel: ObservableObject {
    enum ViewState: Equatable {
        case idle
        case loading
        case content
        case empty
        case error(String)
    }

    @Published private(set) var characters: [Character] = []
    @Published private(set) var viewState: ViewState = .idle
    @Published private(set) var isLoadingNextPage = false
    @Published var searchText: String = ""
    @Published var statusFilter: CharacterStatusFilter = .all

    private let fetchCharactersUseCase: FetchCharactersUseCase
    private var nextPage: Int? = 1
    private var subscriptions = Set<AnyCancellable>()
    private var loadTask: Task<Void, Never>?
    private let debounceInterval: RunLoop.SchedulerTimeType.Stride

    init(
        fetchCharactersUseCase: FetchCharactersUseCase,
        debounceInterval: RunLoop.SchedulerTimeType.Stride = .milliseconds(350)
    ) {
        self.fetchCharactersUseCase = fetchCharactersUseCase
        self.debounceInterval = debounceInterval
        bindQueryChanges()
    }

    func loadInitial() {
        guard viewState == .idle else { return }
        resetAndFetch()
    }

    func retry() {
        resetAndFetch()
    }

    func loadMoreIfNeeded(currentItem: Character) {
        guard let last = characters.last, last.id == currentItem.id else { return }
        fetchNextPage()
    }

    private func bindQueryChanges() {
        Publishers.CombineLatest(
            $searchText.removeDuplicates(),
            $statusFilter.removeDuplicates()
        )
        .debounce(for: debounceInterval, scheduler: RunLoop.main)
        .sink { [weak self] _ in
            self?.resetAndFetch()
        }
        .store(in: &subscriptions)
    }

    private func resetAndFetch() {
        nextPage = 1
        characters = []
        viewState = .loading
        fetchNextPage()
    }

    private func fetchNextPage() {
        guard !isLoadingNextPage, let page = nextPage else { return }
        isLoadingNextPage = true

        let query = CharacterQuery(name: searchText, status: statusFilter)

        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await fetchCharactersUseCase.execute(page: page, query: query)
                guard !Task.isCancelled else { return }

                nextPage = response.info.next
                characters.append(contentsOf: response.characters)
                viewState = characters.isEmpty ? .empty : .content
            } catch {
                if characters.isEmpty {
                    viewState = .error(readableMessage(from: error))
                }
            }

            isLoadingNextPage = false
        }
    }

    private func readableMessage(from error: Error) -> String {
        if let apiError = error as? APIClientError, let description = apiError.errorDescription {
            return description
        }
        return Strings.Errors.generic
    }
}
