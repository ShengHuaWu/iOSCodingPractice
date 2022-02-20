@testable import CodingPractice

final class MockPersistence: Persistence {
    private(set) var storeCallCount = 0
    private(set) var receivedProducts: [Product] = []
    private(set) var getNumberOfProductsCallCount = 0
    
    private(set) var getProductAtIndexCallCount = 0
    private(set) var getProductWithIdCallCount = 0
    private(set) var receivedIndex = 0
    private(set) var receivedProductId = ""
    var expectedProduct: Product!
    
    private(set) var toggleIsFavoritedCallCount = 0
    var expectedIndex: Int!
    
    func store(_ products: [Product]) {
        self.storeCallCount += 1
        self.receivedProducts = products
    }
    
    func getNumberOfProducts() -> Int {
        self.getNumberOfProductsCallCount += 1
        
        return receivedProducts.count
    }
    
    func getProduct(at index: Int) -> Product? {
        self.getProductAtIndexCallCount += 1
        self.receivedIndex = index
        
        return self.expectedProduct
    }
    
    func getProduct(with id: String) -> Product? {
        self.getProductWithIdCallCount += 1
        self.receivedProductId = id
        
        return self.expectedProduct
    }
    
    func toggleIsFavorited(with id: String) -> Int? {
        self.toggleIsFavoritedCallCount += 1
        self.receivedProductId = id
        
        return self.expectedIndex
    }
}
