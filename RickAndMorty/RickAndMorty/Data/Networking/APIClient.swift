import Foundation

protocol APIClient {
    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]) async throws -> T
}

enum APIClientError: LocalizedError {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return Strings.Errors.invalidURL
        case .invalidResponse:
            return Strings.Errors.invalidResponse
        case .statusCode(let code):
            return Strings.Errors.statusCode(code)
        case .decoding:
            return Strings.Errors.decoding
        case .transport(let error):
            return error.localizedDescription
        }
    }
}

struct DefaultAPIClient: APIClient {
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        baseURL: URL = URL(string: "https://rickandmortyapi.com/api")!,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
    }

    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]) async throws -> T {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw APIClientError.invalidURL
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        do {
            let (data, response) = try await session.data(for: request)
#if DEBUG
            debugPrint("[DEBUG][API] GET \(request.url?.absoluteString ?? "")")
            if
                let jsonObject = try? JSONSerialization.jsonObject(with: data),
                let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
                let jsonString = String(data: prettyData, encoding: .utf8)
            {
                debugPrint("[DEBUG][API] Response:\n\(jsonString)")
            }
#endif
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIClientError.invalidResponse
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIClientError.statusCode(httpResponse.statusCode)
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIClientError.decoding(error)
            }
        } catch {
            if let error = error as? APIClientError {
                throw error
            }
            throw APIClientError.transport(error) // [TRADE-OFF] No cache or retry here; simplicity over resilience (can be evolved later).
        }
    }
}
