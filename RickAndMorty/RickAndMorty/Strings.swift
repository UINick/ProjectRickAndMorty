//
//  RickAndMortyApp.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 13/01/26.
//

import Foundation

enum Strings {
    enum Common {
        static let retryButton = String(localized: "Try again")
        static let genericErrorTitle = String(localized: "Something went wrong")
    }

    enum CharacterList {
        static let title = String(localized: "Characters")
        static let searchPlaceholder = String(localized: "Search by name")
        static let statusPickerTitle = String(localized: "Status")
        static let loading = String(localized: "Loading characters...")
        static let emptyTitle = String(localized: "No results")
        static let emptyMessage = String(localized: "Try changing the search or status filter.")
    }

    enum CharacterDetail {
        static let title = String(localized: "Details")
        static let infoTitle = String(localized: "Information")
        static let statusTitle = String(localized: "Status")
        static let speciesTitle = String(localized: "Species")
        static let genderTitle = String(localized: "Gender")
        static let originTitle = String(localized: "Origin")
        static let locationTitle = String(localized: "Location")
        static let episodesTitle = String(localized: "Episodes")
        static func episodesCount(_ count: Int) -> String {
            let singular = String(localized: "episode")
            let plural = String(localized: "episodesLowerCase")
            let suffix = count == 1 ? singular : plural
            return "\(count) \(suffix)"
        }
        static let noEpisodeURLs = String(localized: "No URLs available.")
        static func moreEpisodes(_ remainingCount: Int) -> String {
            String.localizedStringWithFormat(String(localized: "... and %d more"), remainingCount)
        }
        static let loading = String(localized: "Loading details...")
        static let errorTitle = String(localized: "Unable to load")
    }

    enum Status {
        static let all = String(localized: "All")
        static let alive = String(localized: "Alive")
        static let dead = String(localized: "Dead")
        static let unknown = String(localized: "Unknown")
    }

    enum Errors {
        static let generic = String(localized: "Something went wrong. Please try again.")
        static let detailsUnavailable = String(localized: "Unable to load details.")
        static let invalidURL = String(localized: "Invalid URL.")
        static let invalidResponse = String(localized: "Unexpected server response.")
        static func statusCode(_ code: Int) -> String {
            String.localizedStringWithFormat(String(localized: "Request failed (%d)."), code)
        }
        static let decoding = String(localized: "Unable to read data.")
    }
}
