import SwiftUI

struct ShortenerView: View {
    @ObservedObject var viewModel: ShortenerViewModel

    private var isErrorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter URL to shorten", text: $viewModel.urlString)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                        .accessibilityIdentifier("urlTextField")

                    Button(action: {
                        Task {
                            await viewModel.shortenURL()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title)
                        }
                    }
                    .disabled(viewModel.isLoading || viewModel.urlString.isEmpty)
                    .accessibilityIdentifier("shortenButton")
                }
                .padding()

                List(viewModel.shortenedURLs, id: \.alias) { url in
                    VStack(alignment: .leading) {
                        Text(url.links.`self`)
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text(url.links.short)
                            .font(.subheadline)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("URL Shortener")
            .alert("Error", isPresented: isErrorPresented) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred.")
            }
        }
    }
}

#Preview {
    let mockService = MockAPIService()
    let mockResponse = ShortenedURLResponse(alias: "preview", links: Links(self: "https://www.google.com", short: "https://trimly.example/preview"))
    let viewModel: ShortenerViewModel
    
    mockService.performResult = .success(mockResponse)
    viewModel = ShortenerViewModel(apiService: mockService)
    viewModel.shortenedURLs = [
        ShortenedURLResponse(alias: "preview1", links: Links(self: "https://www.google.com", short: "https://trimly.example/preview1")),
        ShortenedURLResponse(alias: "preview2", links: Links(self: "https://www.apple.com", short: "https://trimly.example/preview2"))
    ]

    return ShortenerView(viewModel: viewModel)
}
