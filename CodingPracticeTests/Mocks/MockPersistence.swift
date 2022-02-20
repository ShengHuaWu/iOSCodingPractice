@testable import CodingPractice

final class MockPersistence: Persistence {
    private(set) var storeCallCount = 0
    private(set) var receivedProducts: [Product] = []
    
    private(set) var getProductWithIdCallCount = 0
    private(set) var receivedProductId = ""
    var expectedProduct: Product!
    
    private(set) var toggleIsFavoritedCallCount = 0
    
    func store(_ products: [Product]) {
        self.storeCallCount += 1
        self.receivedProducts = products
    }
    
    func getProduct(with id: String) -> Product? {
        self.getProductWithIdCallCount += 1
        self.receivedProductId = id
        
        return self.expectedProduct
    }
    
    func toggleIsFavorited(with id: String) {
        self.toggleIsFavoritedCallCount += 1
        self.receivedProductId = id
    }
}
