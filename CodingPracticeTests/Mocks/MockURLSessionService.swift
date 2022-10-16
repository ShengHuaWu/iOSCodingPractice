@testable import CodingPractice
import Foundation

final class MockURLSessionService: URLSessionService {
    private(set) var dataCallCount = 0
    
    var expectedError: Error!
    var expectedData: Data!
    var expectedResponse: URLResponse!
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        dataCallCount += 1
        
        if let error = expectedError {
            throw error
        } else {
            return (expectedData, expectedResponse)
        }
    }
}
