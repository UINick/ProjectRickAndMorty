//
//  PageInfo.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 10/01/26.
//

import Foundation

struct PageInfo: Equatable {
    let count: Int
    let pages: Int
    let next: Int?
    let prev: Int?

    var hasNextPage: Bool { next != nil }
}
