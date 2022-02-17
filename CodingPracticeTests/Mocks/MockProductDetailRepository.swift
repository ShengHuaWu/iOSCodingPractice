@testable import CodingPractice

final class MockProductDetailRepository: ProductDetailRepoitoryInterface {
    private(set) var getProductCallCount = 0
    
    private(set) var receivedProductId: String!
    var expectedProduct: Product!
    
    func getProduct(with id: String) -> Product? {
        self.getProductCallCount += 1
        self.receivedProductId = id
        
        return self.expectedProduct
    }
}
