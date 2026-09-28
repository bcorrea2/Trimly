import XCTest
@testable import Trimly

class StringURLTests: XCTestCase {
    func testIsValidURL_ValidURL() {
        XCTAssertTrue("https://www.google.com".isValidURL())
        XCTAssertTrue("http://example.com".isValidURL())
        XCTAssertTrue("https://sub.domain.co.uk/path?query=1#fragment".isValidURL())
    }

    func testIsValidURL_InvalidURL() {
        XCTAssertFalse("".isValidURL())
        XCTAssertFalse("not a url".isValidURL())
        XCTAssertFalse("www.google.com".isValidURL())
    }
}
