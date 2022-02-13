import Foundation
@testable import CodingPractice

final class MockWebService: WebService {
    private(set) var getProductsCallCount = 0
    var expectedProducts: [Product]!
    var expectedError: WebServiceError!
    
    func getProducts(_ completion: @escaping (Result<[Product], WebServiceError>) -> Void) {
        getProductsCallCount += 1
        
        if let error = expectedError {
            completion(.failure(error))
        } else {
            completion(.success(expectedProducts))
        }
    }
}
