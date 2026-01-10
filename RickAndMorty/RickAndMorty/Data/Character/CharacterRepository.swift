import Foundation

protocol CharacterRepository {
    func fetchCharacters(page: Int, query: CharacterQuery) async throws -> CharacterPage
    func fetchCharacter(id: Int) async throws -> Character
}

struct RemoteCharacterRepository: CharacterRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchCharacters(page: Int, query: CharacterQuery) async throws -> CharacterPage {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)")
        ]

        if let name = query.sanitizedName {
            items.append(URLQueryItem(name: "name", value: name))
        }

        if let status = query.status.apiValue {
            items.append(URLQueryItem(name: "status", value: status.lowercased()))
        }

        let response: CharacterResponseDTO = try await client.get("character", queryItems: items)
        return response.toDomain()
    }

    func fetchCharacter(id: Int) async throws -> Character {
        let response: CharacterDTO = try await client.get("character/\(id)", queryItems: [])
        return response.toDomain()
    }
}
