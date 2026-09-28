import XCTest
@testable import Trimly

class APIEndpointTests: XCTestCase {
    struct MockDefaultEndpoint: APIEndpoint {
        typealias ResponseType = String
        var path: String = "default"
        var method: HTTPMethod = .post
    }

    func testAPIEndpoint_DefaultHeaders() {
        let endpoint = MockDefaultEndpoint()
        XCTAssertNotNil(endpoint.headers)
        XCTAssertEqual(endpoint.headers?["Content-Type"], "application/json")
    }

    func testAPIEndpoint_DefaultBody() {
        let endpoint = MockDefaultEndpoint()
        XCTAssertNil(endpoint.body)
    }

    func testHTTPMethod_RawValuesAndExhaustiveness() {
        XCTAssertEqual(HTTPMethod.allCases.count, 1, "New HTTPMethod case added. Please update the test.")

        for httpMethod in HTTPMethod.allCases {
            switch httpMethod {
            case .post:
                XCTAssertEqual(httpMethod.rawValue, "POST")
            }
        }
    }
}
