import Foundation

protocol APIServicing {
    func perform<E: APIEndpoint>(_ endpoint: E) async throws -> E.ResponseType
}

class APIService: APIServicing {
    private let session: URLSessionProtocol
    private let baseURL: URL
    private let encoder: JSONEncoder
    
    private let acceptableStatusCodes = 200..<300
    
    init(
        session: URLSessionProtocol = URLSession.shared,
        baseURL: URL,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.session = session
        self.baseURL = baseURL
        self.encoder = encoder
    }
    
    func perform<E: APIEndpoint>(_ endpoint: E) async throws -> E.ResponseType {
        let url = baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        endpoint.headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        if let body = endpoint.body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.encodingError(error)
            }
        }
        
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              acceptableStatusCodes.contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let responseObject = try JSONDecoder().decode(E.ResponseType.self, from: data)
            return responseObject
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case encodingError(Error)
    case decodingError(Error)
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case (.encodingError, .encodingError):
            return true
        case (.decodingError, .decodingError):
            return true
        default:
            return false
        }
    }
}
