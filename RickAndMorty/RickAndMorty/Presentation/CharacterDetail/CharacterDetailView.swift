//
//  CharacterDetailView.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 10/01/26.
//

import SwiftUI

struct CharacterDetailView: View {
    @StateObject private var viewModel: CharacterDetailViewModel

    init(viewModel: CharacterDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle(Strings.CharacterDetail.title)
            .navigationBarTitleDisplayMode(.inline)
            .task { viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            LoadingDetailView()
        case .error(let message):
            ErrorDetailView(message: message, onRetry: viewModel.retry)
        case .content(let character):
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header(character)
                    infoSection(character)
                    episodesSection(character)
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }

    private func header(_ character: Character) -> some View {
        VStack(spacing: 12) {
            AsyncImage(url: character.imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .secondarySystemBackground))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .background(Color(uiColor: .secondarySystemBackground))
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                @unknown default:
                    EmptyView()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 8) {
                Text(character.name)
                    .font(.title)
                    .fontWeight(.semibold)
                HStack(spacing: 8) {
                    StatusBadge(status: character.status)
                    Text(character.species)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(character.gender)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func infoSection(_ character: Character) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.CharacterDetail.infoTitle)
                .font(.headline)
            InfoRow(title: Strings.CharacterDetail.statusTitle, value: character.status.displayName)
            InfoRow(title: Strings.CharacterDetail.speciesTitle, value: character.species)
            InfoRow(title: Strings.CharacterDetail.genderTitle, value: character.gender)
            InfoRow(title: Strings.CharacterDetail.originTitle, value: character.originName)
            InfoRow(title: Strings.CharacterDetail.locationTitle, value: character.locationName)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func episodesSection(_ character: Character) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Strings.CharacterDetail.episodesTitle)
                .font(.headline)
            Text(Strings.CharacterDetail.episodesCount(character.episodeCount))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if character.episodeURLs.isEmpty {
                Text(Strings.CharacterDetail.noEpisodeURLs)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            } else {
                ForEach(Array(character.episodeURLs.prefix(3)).indexed(), id: \.index) { item in
                    Text(item.element.absoluteString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                if character.episodeURLs.count > 3 {
                    Text(Strings.CharacterDetail.moreEpisodes(character.episodeURLs.count - 3))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct LoadingDetailView: View {
    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
            Text(Strings.CharacterDetail.loading)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ErrorDetailView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 42))
                .foregroundStyle(.orange)
            Text(Strings.CharacterDetail.errorTitle)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(Strings.Common.retryButton, action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct StatusBadge: View {
    let status: CharacterStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(status.color)
                .frame(width: 10, height: 10)
            Text(status.displayName)
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(status.color.opacity(0.15))
        .clipShape(Capsule())
    }
}

private extension Array {
    func indexed() -> [(index: Int, element: Element)] {
        enumerated().map { (index: $0.offset, element: $0.element) }
    }
}

private extension CharacterStatus {
    var color: Color {
        switch self {
        case .alive:
            return .green
        case .dead:
            return .red
        case .unknown:
            return .gray
        }
    }
}
