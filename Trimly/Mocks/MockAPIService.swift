import Foundation

#if DEBUG
class MockAPIService: APIServicing {
    var performResult: Result<Any, Error>?
    var shouldDelay: Bool = false

    func perform<E>(_ endpoint: E) async throws -> E.ResponseType where E : APIEndpoint {
        if shouldDelay {
            try await Task.sleep(for: .seconds(2.0))
        }

        guard let result = performResult else {
            fatalError("MockAPIService.performResult not set")
        }

        switch result {
        case .success(let response):
            if let typedResponse = response as? E.ResponseType {
                return typedResponse
            } else {
                fatalError("MockAPIService response type mismatch. Expected \(E.ResponseType.self), got \(type(of: response))")
            }
        case .failure(let error):
            throw error
        }
    }
}
#endif