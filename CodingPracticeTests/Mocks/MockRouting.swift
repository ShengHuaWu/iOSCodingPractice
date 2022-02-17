@testable import CodingPractice

final class MockRouting: Routing {
    private(set) var presentProductDetailCallCount = 0
    private(set) var receivedProductId: String!
    
    func presentProductDetail(with id: String) {
        self.presentProductDetailCallCount += 1
        self.receivedProductId = id
    }
}
