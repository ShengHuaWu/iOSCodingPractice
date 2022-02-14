@testable import CodingPractice

final class MockRouting: Routing {
    private(set) var presentProductDetailCallCount = 0
    
    func presentProductDetail() {
        presentProductDetailCallCount += 1
    }
}
