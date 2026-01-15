//
//  CharacterListView.swift
//  RickAndMorty
//
//  Created by Nicholas Forte on 09/01/26.
//

import SwiftUI

struct CharacterListView: View {
    @StateObject private var viewModel: CharacterListViewModel

    init(viewModel: CharacterListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                searchBar
                statusFilter
                content
            }
            .padding()
            .navigationTitle(Strings.CharacterList.title)
        }
        .task {
            viewModel.loadInitial()
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(Strings.CharacterList.searchPlaceholder, text: $viewModel.searchText)
                .textInputAutocapitalization(.none)
                .disableAutocorrection(true)
                .submitLabel(.search)
        }
        .padding(12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var statusFilter: some View {
        Picker(Strings.CharacterList.statusPickerTitle, selection: $viewModel.statusFilter) {
            ForEach(CharacterStatusFilter.allCases) { status in
                Text(status.displayName).tag(status)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            LoadingStateView()
        case .error(let message):
            ErrorStateView(message: message, onRetry: viewModel.retry)
        case .empty:
            EmptyStateView()
        case .content:
            listView
        }
    }

    private var listView: some View {
        List {
            ForEach(viewModel.characters) { character in
                NavigationLink {
                    CharacterDetailFactory.make(characterID: character.id)
                } label: {
                    CharacterRowView(character: character)
                }
                .onAppear {
                    viewModel.loadMoreIfNeeded(currentItem: character)
                }
            }

            if viewModel.isLoadingNextPage {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}

private struct CharacterRowView: View {
    let character: Character

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: character.imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 64, height: 64)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 6) {
                Text(character.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 8) {
                    StatusBadge(status: character.status)
                    Text(character.species)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
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

private struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            ProgressView()
            Text(Strings.CharacterList.loading)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.fill.questionmark")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)
            Text(Strings.CharacterList.emptyTitle)
                .font(.headline)
            Text(Strings.CharacterList.emptyMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 42))
                .foregroundStyle(.orange)
            Text(Strings.Common.genericErrorTitle)
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
