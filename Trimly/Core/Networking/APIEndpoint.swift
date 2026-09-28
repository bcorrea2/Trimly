import Foundation

protocol APIEndpoint {
    associatedtype ResponseType: Decodable

    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Encodable? { get }
}

enum HTTPMethod: String, CaseIterable {
    case post = "POST"
}

extension APIEndpoint {
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }

    var body: Encodable? {
        return nil
    }
}
