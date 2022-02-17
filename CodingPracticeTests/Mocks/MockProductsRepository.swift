@testable import CodingPractice

final class MockProductsRepository: ProductsRepositoryInterface {
    private(set) var onProductsChangeCallCount = 0
    private var callback: (Result<[Product], Error>) -> Void = { _ in }
    
    private(set) var getProductsCallCount = 0
    private(set) var getProductIdCallCount = 0
    var expectedProducts: [Product] = []
    var expectedError: Error!
    
    func onProductsChange(_ callback: @escaping (Result<[Product], Error>) -> Void) {
        self.onProductsChangeCallCount += 1
        self.callback = callback
    }
    
    func getProducts() {
        self.getProductsCallCount += 1
        if let error = self.expectedError {
            self.callback(.failure(error))
        } else {
            self.callback(.success(self.expectedProducts))
        }
    }
    
    func getNumberOfProducts() -> Int {
        return expectedProducts.count
    }
    
    func getProductId(at index: Int) -> String? {
        self.getProductIdCallCount += 1
        
        return expectedProducts[index].id
    }
}
