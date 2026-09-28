import Foundation

enum ShortenerEndpoint {
    case shorten(url: String)
}

extension ShortenerEndpoint: APIEndpoint {
    var path: String {
        switch self {
        case .shorten:
            return "alias"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .shorten:
            return .post
        }
    }

    var body: Encodable? {
        switch self {
        case .shorten(let url):
            return ShortenURLRequest(url: url)
        }
    }

    typealias ResponseType = ShortenedURLResponse
}

struct ShortenURLRequest: Codable {
    let url: String
}

struct ShortenedURLResponse: Codable, Equatable, Hashable {
    let alias: String
    let links: Links

    enum CodingKeys: String, CodingKey {
        case alias
        case links = "_links"
    }
}

struct Links: Codable, Equatable, Hashable {
    let `self`: String
    let short: String
}
