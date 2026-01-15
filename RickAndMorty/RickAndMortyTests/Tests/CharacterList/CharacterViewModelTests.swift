//
//  CharacterViewModelTests.swift
//  RickAndMortyTests
//
//  Created by Nicholas Forte on 14/01/26.
//

import XCTest
@testable import RickAndMorty

@MainActor
final class CharacterListViewModelTests: XCTestCase {

    func testLoadInitialSuccessUpdatesStateAndCharacters() async {
        let expectedCharacters = [
            TestCharacter.character(id: 1, name: "Rick"),
            TestCharacter.character(id: 2, name: "Morty")
        ]
        let useCase = FetchCharactersUseCaseMock(results: [
            .success(TestCharacter.page(info: TestCharacter.pageInfo(next: nil), characters: expectedCharacters))
        ])

        let sut = CharacterListViewModel(fetchCharactersUseCase: useCase, debounceInterval: .milliseconds(0))

        sut.loadInitial()
        await Task.yield()
        await Task.yield()

        XCTAssertEqual(sut.viewState, .content)

        XCTAssertEqual(sut.characters, expectedCharacters)
        XCTAssertEqual(useCase.invocations.map(\.page), [1])
        XCTAssertEqual(useCase.invocations.map(\.query.status), [.all])
    }

    func testLoadInitialFailureSetsErrorWhenNoData() async {
        let useCase = FetchCharactersUseCaseMock(results: [.failure(APIClientError.statusCode(500))])
        let sut = CharacterListViewModel(fetchCharactersUseCase: useCase, debounceInterval: .milliseconds(0))

        sut.loadInitial()
        await Task.yield()
        await Task.yield()

        guard case let .error(message) = sut.viewState else {
            return XCTFail("Expected error state")
        }
        XCTAssertEqual(message, Strings.Errors.statusCode(500))

        XCTAssertTrue(sut.characters.isEmpty)
    }

    func testLoadMoreAppendsNextPage() async {
        let firstPageCharacters = [
            TestCharacter.character(id: 1, name: "Rick"),
            TestCharacter.character(id: 2, name: "Morty")
        ]
        let secondPageCharacters = [
            TestCharacter.character(id: 3, name: "Summer")
        ]
        let useCase = FetchCharactersUseCaseMock(results: [
            .success(TestCharacter.page(info: TestCharacter.pageInfo(next: 2), characters: firstPageCharacters)),
            .success(TestCharacter.page(info: TestCharacter.pageInfo(next: nil), characters: secondPageCharacters))
        ])

        let sut = CharacterListViewModel(fetchCharactersUseCase: useCase, debounceInterval: .milliseconds(0))

        sut.loadInitial()
        await Task.yield()
        await Task.yield()

        sut.loadMoreIfNeeded(currentItem: firstPageCharacters.last!)
        await Task.yield()
        await Task.yield()

        XCTAssertEqual(sut.characters.count, firstPageCharacters.count + secondPageCharacters.count)
        XCTAssertEqual(useCase.invocations.map(\.page), [1, 2])
        XCTAssertFalse(sut.isLoadingNextPage)
    }

    func testSearchChangeResetsAndRefetchesFirstPage() async {
        let initialCharacters = [TestCharacter.character(id: 1, name: "Rick")]
        let filteredCharacters = [TestCharacter.character(id: 2, name: "Birdperson")]
        let useCase = FetchCharactersUseCaseMock(results: [
            .success(TestCharacter.page(info: TestCharacter.pageInfo(next: nil), characters: initialCharacters)),
            .success(TestCharacter.page(info: TestCharacter.pageInfo(next: nil), characters: filteredCharacters))
        ])

        let sut = CharacterListViewModel(fetchCharactersUseCase: useCase, debounceInterval: .milliseconds(0))

        sut.loadInitial()
        await Task.yield()
        await Task.yield()

        sut.searchText = "Bird"
        try? await Task.sleep(nanoseconds: 100_000_000) // allow debounce + fetch to complete
        await Task.yield()
        await Task.yield()

        XCTAssertEqual(sut.viewState, .content)
        XCTAssertEqual(sut.characters, filteredCharacters)
        XCTAssertEqual(useCase.invocations.count, 2)
        XCTAssertEqual(useCase.invocations.map(\.page), [1, 1])
        XCTAssertEqual(useCase.invocations.last?.query.name, "Bird")
        XCTAssertFalse(sut.isLoadingNextPage)
    }
}
