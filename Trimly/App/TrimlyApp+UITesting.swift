import Foundation

extension TrimlyApp {
    func createMockAPIService() -> APIServicing {
        let mock = MockAPIService()

        if ProcessInfo.processInfo.arguments.contains("-mock-delay-enabled") {
            mock.shouldDelay = true
        }

        if ProcessInfo.processInfo.arguments.contains("-api-error") {
            mock.performResult = .failure(NetworkError.invalidResponse)
        } else {
            let mockResponse = ShortenedURLResponse(alias: "uitest", links: Links(self: "https://www.apple.com", short: "https://trimly.example/uitest"))
            mock.performResult = .success(mockResponse)
        }

        return mock
    }
}
