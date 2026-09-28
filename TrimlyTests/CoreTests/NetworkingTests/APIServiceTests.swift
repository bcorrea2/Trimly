import XCTest
@testable import Trimly

// MARK: - Mocks and Supporting Types

class MockURLSession: URLSessionProtocol {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        return (data ?? Data(), response ?? URLResponse())
    }
}

class MockJSONEncoder: JSONEncoder, @unchecked Sendable {
    var error: Error?

    override func encode<T: Encodable>(_ value: T) throws -> Data {
        if let error = error {
            throw error
        }
        return try super.encode(value)
    }
}

struct MockEndpoint: APIEndpoint {
    typealias ResponseType = MockResponse
    var path: String = "test"
    var method: HTTPMethod = .post
    var body: Encodable? = nil
}

struct MockResponse: Codable, Equatable {
    let id: Int
    let name: String
}

// MARK: - NetworkError Tests

class NetworkErrorTests: XCTestCase {
    func testNetworkError_Equatable() {
        let error1 = NetworkError.invalidURL
        let error2 = NetworkError.invalidResponse
        let error3 = NetworkError.encodingError(EncodingError.invalidValue("1", .init(codingPath: [], debugDescription: "")))
        let error4 = NetworkError.decodingError(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "")))
        
        XCTAssertEqual(error1, .invalidURL)
        XCTAssertNotEqual(error1, error2)
        XCTAssertEqual(error3, .encodingError(EncodingError.invalidValue("2", .init(codingPath: [], debugDescription: ""))))
        XCTAssertEqual(error4, .decodingError(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: ""))))
        XCTAssertNotEqual(error3, error4)
    }
}


// MARK: - APIService Tests

@MainActor
class APIServiceTests: XCTestCase {
    var mockSession: MockURLSession!
    var apiService: APIService!
    let baseURL = URL(string: "https://api.test.com")!

    override func setUp() {
        super.setUp() 
        mockSession = MockURLSession()
        apiService = APIService(session: mockSession, baseURL: baseURL)
    }

    // MARK: Success Tests
    func testPerform_Success() async throws {
        let expectedResponse = MockResponse(id: 1, name: "Test Name")
        let responseData = try JSONEncoder().encode(expectedResponse)
        mockSession.data = responseData
        mockSession.response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        let endpoint = MockEndpoint()

        let result = try await apiService.perform(endpoint)

        XCTAssertEqual(result, expectedResponse)
    }

    func testPerform_Success_WithBody() async throws {
        let requestBody = MockResponse(id: 1, name: "Request Body")
        let endpoint = MockEndpoint(body: requestBody)
        
        let expectedResponse = MockResponse(id: 2, name: "Test Response")
        let responseData = try JSONEncoder().encode(expectedResponse)
        mockSession.data = responseData
        mockSession.response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)

        let result = try await apiService.perform(endpoint)

        XCTAssertEqual(result, expectedResponse)
    }

    // MARK: Failure Tests
    func testPerform_Failure_InvalidResponse() async {
        mockSession.response = HTTPURLResponse(url: baseURL, statusCode: 404, httpVersion: nil, headerFields: nil)
        let endpoint = MockEndpoint()

        do {
            _ = try await apiService.perform(endpoint)
            XCTFail("The service should have thrown an error for an invalid response.")
        } catch {
            XCTAssertEqual(error as? NetworkError, .invalidResponse)
        }
    }
    
    func testPerform_Failure_DecodingError() async {
        mockSession.data = Data("invalid json".utf8)
        mockSession.response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        let endpoint = MockEndpoint()

        do {
            _ = try await apiService.perform(endpoint)
            XCTFail("The service should have thrown a decoding error.")
        } catch let error as NetworkError {
            if case .decodingError = error {
            } else {
                XCTFail("Incorrect error type thrown. Expected .decodingError, got \(error)")
            }
        } catch {
            XCTFail("An unexpected error type was thrown.")
        }
    }
    
    func testPerform_Failure_NetworkError() async {
        struct TestError: Error {}
        mockSession.error = TestError()
        let endpoint = MockEndpoint()
        
        do {
            _ = try await apiService.perform(endpoint)
            XCTFail("The service should have re-thrown the session error.")
        } catch {
            XCTAssert(error is TestError)
        }
    }

    func testPerform_Failure_EncodingError() async {
        let mockEncoder = MockJSONEncoder()
        mockEncoder.error = EncodingError.invalidValue("test", .init(codingPath: [], debugDescription: ""))
        apiService = APIService(session: mockSession, baseURL: baseURL, encoder: mockEncoder)
        let endpoint = MockEndpoint(body: MockResponse(id: 1, name: "test"))

        do {
            _ = try await apiService.perform(endpoint)
            XCTFail("The service should have thrown an encodingError.")
        } catch let error as NetworkError {
            if case .encodingError = error {
            } else {
                XCTFail("Incorrect error type thrown. Expected .encodingError, got \(error)")
            }
        } catch {
            XCTFail("An unexpected error type was thrown.")
        }
    }
}