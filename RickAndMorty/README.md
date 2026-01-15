## RickAndMorty

### How to run
- Requirements: Xcode 15+, iOS 17+ simulator.
- Open `RickAndMorty.xcodeproj`, select scheme `RickAndMorty`, choose an iOS Simulator (e.g., iPhone 15), then Run.
- To run tests: in Xcode Test (⌘U) or via CLI:
  - `xcodebuild test -scheme RickAndMorty -destination 'platform=iOS Simulator,name=iPhone 15'`

### Architecture (Clean)
- **Presentation**: SwiftUI + ObservableObject view models (`CharacterListViewModel`, `CharacterDetailViewModel`) expose published state and handle UI intents (load, retry, paginate, search).
- **Domain**: Pure protocols/entities/use cases (`FetchCharactersUseCase`, `FetchCharacterDetailUseCase`, `Character`, `PageInfo`) with no framework coupling.
- **Data**: Repositories and DTO mapping (`RemoteCharacterRepository`, `CharacterDTO`, `CharacterResponseDTO`) and `APIClient` abstraction with `DefaultAPIClient`.
- Factories (`CharacterListFactory`, `CharacterDetailFactory`) compose layers, keeping assembly at the app edge.
- Rationale: clear boundaries for testability, replaceability (e.g., mock data, different clients), and easier maintenance.

### Dependency Injection
- Constructor injection everywhere: view models receive use cases; use cases receive repositories; repositories receive the `APIClient`.
- Composition roots:
  - `CharacterListFactory` builds `CharacterListViewModel` with `DefaultFetchCharactersUseCase` + `RemoteCharacterRepository` + `DefaultAPIClient`.
  - `CharacterDetailFactory` builds `CharacterDetailViewModel` with `DefaultFetchCharacterDetailUseCase` + `RemoteCharacterRepository` + `DefaultAPIClient`.
- Tests replace dependencies with mocks/stubs (`FetchCharactersUseCaseMock`, `FetchCharacterDetailUseCaseMock`, `APIClientStub`) for deterministic behavior.

### What is tested (and why)
- **Presentation** (business logic only): `CharacterListViewModelTests`, `CharacterDetailViewModelTests`
  - Initial load success/error, pagination append, search resets to page 1, retry flows; ensures state transitions and requests are correct without UI/rendering.
- **Data**: `RemoteCharacterRepositoryTests`
  - Successful decode/mapping of list, propagation of HTTP errors (404), and decoding failure surfacing; ensures repository contracts and query parameters are correct.
- Deterministic: all tests use in-memory stubs/mocks; no real network.

### Observability & Security
- Observability: lightweight—state exposed via `@Published` for UI/reactive inspection; errors converted to user-friendly messages. No external logging/analytics yet.
- Networking: `DefaultAPIClient` enforces HTTPS base URL, validates HTTP status, and normalizes errors. No persistent tokens/PII handled. Decoding errors mapped to readable messages.

### Next steps / Improvements
- Add snapshot/UI tests for key screens (empty/error/content).
- Introduce structured logging (os_log) and lightweight metrics for request timing and failures.
- Add caching (e.g., response cache for characters) and offline handling.
- Expand error typing (e.g., rate limiting) and retry/backoff strategies.
- Add accessibility pass for SwiftUI views (labels, traits, dynamic type audit).
