import Foundation

enum CharacterStatus: String, Codable, Equatable {
    case alive = "Alive"
    case dead = "Dead"
    case unknown = "unknown"

    var displayName: String {
        switch self {
        case .alive:
            return Strings.Status.alive
        case .dead:
            return Strings.Status.dead
        case .unknown:
            return Strings.Status.unknown
        }
    }
}

enum CharacterStatusFilter: String, CaseIterable, Identifiable {
    case all
    case alive
    case dead
    case unknown

    var id: Self { self }

    var apiValue: String? {
        switch self {
        case .all:
            return nil
        default:
            return rawValue
        }
    }

    var displayName: String {
        switch self {
        case .all:
            return Strings.Status.all
        case .alive:
            return Strings.Status.alive
        case .dead:
            return Strings.Status.dead
        case .unknown:
            return Strings.Status.unknown
        }
    }
}

struct Character: Identifiable, Equatable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let gender: String
    let originName: String
    let locationName: String
    let imageURL: URL?
    let episodeURLs: [URL]
    let episodeCount: Int
}

struct CharacterPage: Equatable {
    let info: PageInfo
    let characters: [Character]
}

struct CharacterQuery: Equatable {
    var name: String?
    var status: CharacterStatusFilter

    init(name: String? = nil, status: CharacterStatusFilter = .all) {
        self.name = name
        self.status = status
    }

    var sanitizedName: String? {
        guard let value = name?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        return value
    }
}
