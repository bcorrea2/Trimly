import XCTest

@MainActor
final class TrimlyUITests: XCTestCase {
    override func setUp() async throws {
        try await super.setUp()
        XCUIDevice.shared.orientation = .portrait
    }
    
    func testShortenURLFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]

        app.launch()

        let urlTextField = app.textFields["urlTextField"]
        let shortenButton = app.buttons["shortenButton"]

        XCTAssertTrue(urlTextField.exists)
        urlTextField.tap()
        urlTextField.typeText("https://www.apple.com")

        XCTAssertTrue(shortenButton.exists)
        shortenButton.tap()

        let newShortenedURLCell = app.staticTexts["https://trimly.example/uitest"]

        XCTAssertTrue(newShortenedURLCell.waitForExistence(timeout: 5))
    }
    
    func testShortenURL_InvalidInputShowsError() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()

        let urlTextField = app.textFields["urlTextField"]
        let shortenButton = app.buttons["shortenButton"]

        XCTAssertTrue(urlTextField.exists)
        urlTextField.tap()
        urlTextField.typeText("not a valid url")

        XCTAssertTrue(shortenButton.exists)
        shortenButton.tap()

        let errorAlert = app.alerts["Error"]
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 5))
        XCTAssertTrue(errorAlert.staticTexts["The provided URL is not valid."].exists)
        errorAlert.buttons["OK"].tap()
        XCTAssertFalse(errorAlert.exists)
    }

    func testShortenURL_APIFailureShowsError() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-api-error"]
        app.launch()

        let urlTextField = app.textFields["urlTextField"]
        let shortenButton = app.buttons["shortenButton"]

        XCTAssertTrue(urlTextField.exists)
        urlTextField.tap()
        urlTextField.typeText("https://www.google.com")

        XCTAssertTrue(shortenButton.exists)
        shortenButton.tap()

        let errorAlert = app.alerts["Error"]
        XCTAssertTrue(errorAlert.waitForExistence(timeout: 5))
        XCTAssertTrue(errorAlert.staticTexts["The server returned an invalid response."].exists)
        errorAlert.buttons["OK"].tap()
        XCTAssertFalse(errorAlert.exists)
    }

    func testShortenURL_ShowsLoadingIndicator() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing", "-mock-delay-enabled"]
        app.launch()

        let urlTextField = app.textFields["urlTextField"]
        let shortenButton = app.buttons["shortenButton"]
        let loadingIndicator = app.activityIndicators.firstMatch

        XCTAssertTrue(urlTextField.exists)
        urlTextField.tap()
        urlTextField.typeText("https://www.google.com")

        XCTAssertTrue(shortenButton.exists)
        shortenButton.tap()

        XCTAssertTrue(loadingIndicator.waitForExistence(timeout: 1))
        XCTAssertTrue(loadingIndicator.exists)
    }
}
