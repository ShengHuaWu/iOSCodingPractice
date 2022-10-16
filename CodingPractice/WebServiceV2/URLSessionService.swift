import Foundation

protocol URLSessionService {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionService {}
