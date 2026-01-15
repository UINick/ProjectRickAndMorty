//
//  TestCharacter.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 14/01/26.
//

import Foundation
@testable import RickAndMorty

enum TestCharacter {
    static func character(id: Int = 1, name: String = "Rick") -> Character {
        Character(
            id: id,
            name: name,
            status: .alive,
            species: "Human",
            gender: "Male",
            originName: "Earth",
            locationName: "Earth",
            imageURL: URL(string: "https://example.com/\(id).png"),
            episodeURLs: [],
            episodeCount: 0
        )
    }

    static func pageInfo(next: Int?) -> PageInfo {
        PageInfo(count: 1, pages: 1, next: next, prev: nil)
    }

    static func page(info: PageInfo, characters: [Character]) -> CharacterPage {
        CharacterPage(info: info, characters: characters)
    }
}
