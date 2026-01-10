import Foundation

struct CharacterResponseDTO: Decodable {
    let info: InfoDTO
    let results: [CharacterDTO]
}

struct InfoDTO: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct CharacterDTO: Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
    let origin: LocationDTO
    let location: LocationDTO
    let image: String
    let episode: [String]
}

struct LocationDTO: Decodable {
    let name: String
}

extension CharacterResponseDTO {
    func toDomain() -> CharacterPage {
        CharacterPage(
            info: info.toDomain(),
            characters: results.map { $0.toDomain() }
        )
    }
}

extension InfoDTO {
    func toDomain() -> PageInfo {
        PageInfo(
            count: count,
            pages: pages,
            next: next.flatMap(Self.pageNumber(from:)),
            prev: prev.flatMap(Self.pageNumber(from:))
        )
    }

    static func pageNumber(from urlString: String?) -> Int? {
        guard
            let urlString,
            let components = URLComponents(string: urlString),
            let pageItem = components.queryItems?.first(where: { $0.name == "page" }),
            let value = pageItem.value,
            let number = Int(value)
        else {
            return nil
        }
        return number
    }
}

extension CharacterDTO {
    func toDomain() -> Character {
        Character(
            id: id,
            name: name,
            status: CharacterStatus(apiValue: status),
            species: species,
            gender: gender,
            originName: origin.name,
            locationName: location.name,
            imageURL: URL(string: image),
            episodeURLs: episode.compactMap { URL(string: $0) },
            episodeCount: episode.count
        )
    }
}

extension CharacterStatus {
    init(apiValue: String) {
        switch apiValue.lowercased() {
        case "alive":
            self = .alive
        case "dead":
            self = .dead
        default:
            self = .unknown
        }
    }
}
