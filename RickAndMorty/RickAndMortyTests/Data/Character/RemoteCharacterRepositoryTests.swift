//
//  RemoteCharacterRepositoryTests.swift
//  RickAndMortyTests
//
//  Created by Nicholas Forte on 14/01/26.
//

import XCTest
@testable import RickAndMorty

@MainActor
final class RemoteCharacterRepositoryTests: XCTestCase {

    func testFetchCharactersSuccessMapsResponse() async throws {
        let listJSON = """
        {
          "info": {
            "count": 2,
            "pages": 1,
            "next": "https://rickandmortyapi.com/api/character?page=2",
            "prev": null
          },
          "results": [
            {
              "id": 1,
              "name": "Rick",
              "status": "Alive",
              "species": "Human",
              "gender": "Male",
              "origin": { "name": "Earth" },
              "location": { "name": "Earth" },
              "image": "https://example.com/1.png",
              "episode": ["https://rickandmortyapi.com/api/episode/1"]
            },
            {
              "id": 2,
              "name": "Morty",
              "status": "Dead",
              "species": "Human",
              "gender": "Male",
              "origin": { "name": "Citadel" },
              "location": { "name": "Citadel" },
              "image": "https://example.com/2.png",
              "episode": []
            }
          ]
        }
        """.data(using: .utf8)!

        let client = APIClientStub(responses: [
            "character": .success(listJSON)
        ])
        let repository = RemoteCharacterRepository(client: client)

        let query = CharacterQuery(name: " Rick ", status: .alive)
        let page = try await repository.fetchCharacters(page: 1, query: query)

        XCTAssertEqual(client.requests.first?.path, "character")
        let sentItems = client.requests.first?.queryItems
        XCTAssertTrue(sentItems?.contains(where: { $0.name == "page" && $0.value == "1" }) == true)
        XCTAssertTrue(sentItems?.contains(where: { $0.name == "name" && $0.value == "Rick" }) == true)
        XCTAssertTrue(sentItems?.contains(where: { $0.name == "status" && $0.value == "alive" }) == true)

        XCTAssertEqual(page.info.next, 2)
        XCTAssertEqual(page.characters.count, 2)
        XCTAssertEqual(page.characters[0].name, "Rick")
        XCTAssertEqual(page.characters[1].status, .dead)
    }

    func testFetchCharacterPropagatesStatusError() async {
        let client = APIClientStub(responses: [
            "character/404": .failure(APIClientError.statusCode(404))
        ])
        let repository = RemoteCharacterRepository(client: client)

        await XCTAssertThrowsErrorAsync(try await repository.fetchCharacter(id: 404)) { error in
            guard let apiError = error as? APIClientError else {
                return XCTFail("Expected APIClientError, got \(type(of: error))")
            }
            switch apiError {
            case .statusCode(let code):
                XCTAssertEqual(code, 404)
            default:
                XCTFail("Expected statusCode(404), got \(apiError)")
            }
        }
    }

    func testFetchCharactersDecodingError() async {
        let client = APIClientStub(responses: [
            "character": .success(Data("{}".utf8))
        ])
        let repository = RemoteCharacterRepository(client: client)

        await XCTAssertThrowsErrorAsync(try await repository.fetchCharacters(page: 1, query: CharacterQuery())) { error in
            guard case let .decoding(decodingError)? = error as? APIClientError else {
                return XCTFail("Expected decoding error")
            }
            XCTAssertNotNil(decodingError)
        }
    }
}
