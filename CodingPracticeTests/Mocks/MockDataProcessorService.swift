@testable import CodingPractice
import Foundation

final class MockDataProcessorService: DataProcessorService {
    private(set) var processCallCount = 0
    
    var expectedError: Error!
    var expectedModel: Any!
    
    func process<T>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        errorContext: String
    ) throws -> T where T : Decodable {
        processCallCount += 1
        
        if let error = expectedError {
            throw error
        } else {
            return expectedModel as! T
        }
    }
}
