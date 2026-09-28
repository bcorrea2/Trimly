import Foundation
import Combine

@MainActor
class ShortenerViewModel: ObservableObject {
    @Published var urlString: String = ""
    @Published var shortenedURLs: [ShortenedURLResponse] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let apiService: APIServicing

    init(apiService: APIServicing) {
        self.apiService = apiService
    }

    func shortenURL() async {
        guard urlString.isValidURL() else {
            errorMessage = ShortenerError.invalidURL.localizedDescription
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let endpoint = ShortenerEndpoint.shorten(url: urlString)
            let shortenedURL = try await apiService.perform(endpoint)

            shortenedURLs.insert(shortenedURL, at: 0)
            urlString = ""
        } catch let networkError as NetworkError {
            switch networkError {
            case .invalidURL:
                errorMessage = ShortenerError.invalidURL.localizedDescription
            case .invalidResponse:
                errorMessage = ShortenerError.invalidResponse.localizedDescription
            case .encodingError:
                errorMessage = ShortenerError.encodingFailed.localizedDescription
            case .decodingError:
                errorMessage = ShortenerError.decodingFailed.localizedDescription
            }
        } catch {
            self.errorMessage = ShortenerError.generic.localizedDescription
        }

        isLoading = false
    }
}

extension ShortenerViewModel {
    public enum ShortenerError: LocalizedError, Equatable {
        case invalidURL
        case invalidResponse
        case encodingFailed
        case decodingFailed
        case generic

        public var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "The provided URL is not valid."
            case .invalidResponse:
                return "The server returned an invalid response."
            case .encodingFailed:
                return "Failed to prepare the request."
            case .decodingFailed:
                return "Failed to process the server response."
            case .generic:
                return "An unknown error occurred. Please try again."
            }
        }
    }
}
