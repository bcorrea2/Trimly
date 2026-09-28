import XCTest
@testable import Trimly

@MainActor
class ShortenerEndpointTests: XCTestCase {
    func testShortenEndpoint_Configuration() throws {
        let testURL = "https://www.google.com"
        let endpoint = ShortenerEndpoint.shorten(url: testURL)

        XCTAssertEqual(endpoint.path, "alias")
        XCTAssertEqual(endpoint.method, .post)

        let body = try XCTUnwrap(endpoint.body as? ShortenURLRequest)
        XCTAssertEqual(body.url, testURL)
    }

    func testShortenedURLResponse_Decoding() throws {
        let jsonString = """
        {
            "alias": "34548516",
            "_links": {
                "self": "https://open.spotify.com",
                "short": "https://url-shortener-server.onrender.com/api/alias/34548516"
            }
        }
        """
        let jsonData = Data(jsonString.utf8)
        let decodedResponse = try JSONDecoder().decode(ShortenedURLResponse.self, from: jsonData)
        let expectedResponse = ShortenedURLResponse(
            alias: "34548516",
            links: Links(
                self: "https://open.spotify.com",
                short: "https://url-shortener-server.onrender.com/api/alias/34548516"
            )
        )
        
        XCTAssertEqual(decodedResponse, expectedResponse)
    }
}
