import XCTest
@testable import Trimly

@MainActor
class ShortenerViewModelTests: XCTestCase {
    var viewModel: ShortenerViewModel!
    var mockService: MockAPIService!

    override func setUp() {
        super.setUp()
        mockService = MockAPIService()
    }

    func testShortenURL_Success() async {
        let expectedResponse = ShortenedURLResponse(alias: "test", links: Links(self: "original", short: "short"))
        mockService.performResult = .success(expectedResponse)
        viewModel = ShortenerViewModel(apiService: mockService)
        viewModel.urlString = "https://www.google.com"

        await viewModel.shortenURL()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.shortenedURLs.count, 1)
        XCTAssertEqual(viewModel.shortenedURLs.first, expectedResponse)
        XCTAssertTrue(viewModel.urlString.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testShortenURL_Failure() async {
        mockService.performResult = .failure(NetworkError.invalidResponse)
        viewModel = ShortenerViewModel(apiService: mockService)
        viewModel.urlString = "https://www.google.com"

        await viewModel.shortenURL()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.shortenedURLs.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, ShortenerViewModel.ShortenerError.invalidResponse.localizedDescription)
    }

    func testShortenURL_InvalidURLString() async {
        class FailingMock: MockAPIService {
            override func perform<E>(_ endpoint: E) async throws -> E.ResponseType where E : APIEndpoint {
                XCTFail("The network service should not be called for an invalid URL.")
                return try await super.perform(endpoint)
            }
        }
        let failingMock = FailingMock()
        failingMock.performResult = .success(ShortenedURLResponse(alias: "", links: .init(self: "", short: "")))

        viewModel = ShortenerViewModel(apiService: failingMock)
        viewModel.urlString = "not a valid url"

        await viewModel.shortenURL()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.shortenedURLs.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, ShortenerViewModel.ShortenerError.invalidURL.localizedDescription)
    }

    func testShortenURL_MapsNetworkErrorInvalidURLToUserErrorInvalidURL() async {
        mockService.performResult = .failure(NetworkError.invalidURL)
        viewModel = ShortenerViewModel(apiService: mockService)
        viewModel.urlString = "https://www.google.com"

        await viewModel.shortenURL()

        XCTAssertEqual(viewModel.errorMessage, ShortenerViewModel.ShortenerError.invalidURL.localizedDescription)
    }

    func testShortenURL_MapsNetworkErrorInvalidResponseToUserErrorInvalidResponse() async {
        mockService.performResult = .failure(NetworkError.invalidResponse)
        viewModel = ShortenerViewModel(apiService: mockService)
        viewModel.urlString = "https://www.google.com"

        await viewModel.shortenURL()

        XCTAssertEqual(viewModel.errorMessage, ShortenerViewModel.ShortenerError.invalidResponse.localizedDescription)
    }

    func testShortenURL_MapsNetworkErrorEncodingErrorToUserErrorEncodingFailed() async {
        let encodingError = EncodingError.invalidValue("test", .init(codingPath: [], debugDescription: ""))
        mockService.performResult = .failure(NetworkError.encodingError(encodingError))
        viewModel = ShortenerViewModel(apiService: mockService)
        viewModel.urlString = "https://www.google.com"

        await viewModel.shortenURL()

        XCTAssertEqual(viewModel.errorMessage, ShortenerViewModel.ShortenerError.encodingFailed.localizedDescription)
    }

    func testShortenURL_MapsNetworkErrorDecodingErrorToUserErrorDecodingFailed() async {
        let decodingError = DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: ""))
        mockService.performResult = .failure(NetworkError.decodingError(decodingError))
        viewModel = ShortenerViewModel(apiService: mockService)
        viewModel.urlString = "https://www.google.com"

        await viewModel.shortenURL()

        XCTAssertEqual(viewModel.errorMessage, ShortenerViewModel.ShortenerError.decodingFailed.localizedDescription)
    }

    func testShortenURL_MapsGenericErrorToUserErrorGeneric() async {
        struct SomeOtherError: Error {}
        mockService.performResult = .failure(SomeOtherError())
        viewModel = ShortenerViewModel(apiService: mockService)
        viewModel.urlString = "https://www.google.com"

        await viewModel.shortenURL()

        XCTAssertEqual(viewModel.errorMessage, ShortenerViewModel.ShortenerError.generic.localizedDescription)
    }
}
