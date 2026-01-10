//
//  RickAndMortyApp.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 09/01/26.
//

import SwiftUI

@main
struct RickAndMortyApp: App {
    var body: some Scene {
        WindowGroup {
            CharacterListFactory.make()
        }
    }
}
