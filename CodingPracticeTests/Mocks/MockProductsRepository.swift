@testable import CodingPractice

final class MockProductsRepository: ProductsRepositoryInterface {
    private(set) var onProductsChangeCallCount = 0
    private var callback: (ProductsRepositoryState) -> Void = { _ in }
    
    private(set) var getProductsCallCount = 0
    private(set) var getProductCallCount = 0
    var expectedProducts: [Product] = []
    var expectedError: Error!
    
    func onProductsChange(_ callback: @escaping (ProductsRepositoryState) -> Void) {
        self.onProductsChangeCallCount += 1
        self.callback = callback
    }
    
    func getProducts() {
        self.getProductsCallCount += 1
        if self.expectedError != nil {
            self.callback(.error)
        } else {
            self.callback(.updateAll)
        }
    }
    
    func getNumberOfProducts() -> Int {
        return expectedProducts.count
    }
    
    func getProduct(at index: Int) -> Product? {
        self.getProductCallCount += 1
        
        return self.expectedProducts[index]
    }
}
