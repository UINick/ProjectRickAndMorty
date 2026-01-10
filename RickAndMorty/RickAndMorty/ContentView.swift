//
//  ContentView.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 09/01/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CharacterListFactory.make()
            }
        }

#Preview {
    ContentView()
}
