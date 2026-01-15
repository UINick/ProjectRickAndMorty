//
//  CharacterDetailViewModelTests.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 14/01/26.
//
import Combine
import XCTest
@testable import RickAndMorty

@MainActor
final class CharacterDetailViewModelTests: XCTestCase {

    func testLoadSuccessSetsContent() async {
        let character = TestCharacter.character(id: 10, name: "Squanchy")
        let useCase = FetchCharacterDetailUseCaseMock(results: [.success(character)])
        let sut = CharacterDetailViewModel(characterID: 10, fetchCharacterDetailUseCase: useCase)

        sut.load()
        await Task.yield()
        await Task.yield()

        guard case let .content(loaded) = sut.state else {
            return XCTFail("Expected .content")
        }
        XCTAssertEqual(loaded, character)

        XCTAssertEqual(useCase.invocations, [10])
    }

    func testRetryAfterFailureLoadsAgain() async {
        let failingUseCase = FetchCharacterDetailUseCaseMock(results: [
            .failure(APIClientError.invalidResponse),
            .success(TestCharacter.character(id: 11, name: "Mr. Poopybutthole"))
        ])
        let sut = CharacterDetailViewModel(characterID: 11, fetchCharacterDetailUseCase: failingUseCase)

        sut.load()
        await Task.yield()
        await Task.yield()

        guard case let .error(message) = sut.state else {
            return XCTFail("Expected .error after first load")
        }
        XCTAssertEqual(message, Strings.Errors.invalidResponse)

        sut.retry()
        await Task.yield()
        await Task.yield()

        guard case .content = sut.state else {
            return XCTFail("Expected .content after retry")
        }

        XCTAssertEqual(failingUseCase.invocations, [11, 11])
    }
}

