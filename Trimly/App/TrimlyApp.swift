import SwiftUI

@main
struct TrimlyApp: App {
    var body: some Scene {
        WindowGroup {
            ShortenerView(viewModel: createViewModel())
        }
    }

    private func createViewModel() -> ShortenerViewModel {
        let apiService: APIServicing

        if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
            apiService = createMockAPIService()
        } else {
            guard let baseURL = URL(string: "https://url-shortener-server.onrender.com/api/") else {
                fatalError("Invalid base URL")
            }

            apiService = APIService(baseURL: baseURL)
        }

        return ShortenerViewModel(apiService: apiService)
    }
}