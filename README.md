## RickAndMorty
The main goal was to deliver a clean, maintainable solution without over-engineering.

---

## ▶️ Running the app

### Requirements
- Xcode 15+
- iOS 17+ simulator

### Steps
1. Open `RickAndMorty.xcodeproj`
2. Select the `RickAndMorty` scheme
3. Run on an iOS simulator (e.g. iPhone 15)

## 🎥 Demo
[demoVideo.mp4](ProjectRickAndMorty/demoVideo.mp4) *


## Architecture

The project follows **Clean Architecture** to keep features easy to change and easy to test.

### Presentation
- SwiftUI views with `ObservableObject` ViewModels
- ViewModels handle user intents:
  - initial load
  - pagination
  - search
  - retry on error
- UI state is exposed via published properties

### Domain
- Pure business logic
- Entities and use cases:
  - `Character`
  - `PageInfo`
  - `FetchCharactersUseCase`
  - `FetchCharacterDetailUseCase`
- No dependency on UI or networking frameworks

### Data
- Repositories and DTOs responsible for API mapping
- Built on top of an abstract `APIClient`
- `DefaultAPIClient` handles requests, status code validation, and error normalization

### Composition
- Small factory objects act as composition roots
- All dependencies are assembled at the app edge

---

## Dependency Injection

- Constructor injection is used throughout the app
- ViewModels receive use cases
- Use cases receive repositories
- Repositories receive the API client

Factories are responsible for wiring dependencies.  
Tests replace implementations with stubs and mocks for full control.

---

## Testing

### Coverage

#### Presentation
- ViewModel tests for success and error states
- Pagination and search reset behavior
- Retry flows

#### Data
- Repository tests for decoding, mapping, and error propagation

### Notes
- No real network calls are made
- All tests use in-memory stubs

---

## Observability & Security

### Observability
- State is observable via published properties
- Errors are mapped to user-friendly messages
- No logging or analytics implemented yet

### Security
- No token or sensitive data persistence
- No hardcoded secrets

---

## 🚀 Next steps

- Simple cache / offline support
- UI or snapshot tests
- Accessibility improvements

