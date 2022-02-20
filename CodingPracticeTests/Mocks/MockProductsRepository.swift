@testable import CodingPractice

final class MockProductsRepository: ProductsRepository {
    private(set) var onProductsChangeCallCount = 0
    private var callback: (ProductsRepositoryState) -> Void = { _ in }
    
    private(set) var getProductsCallCount = 0
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
            self.callback(.updateAll(self.expectedProducts))
        }
    }
}
