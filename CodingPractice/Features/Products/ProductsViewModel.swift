import Foundation

final class ProductsViewModel {
    private let repository: ProductsRepositoryInterface
    private weak var routing: Routing?
    
    private var callback: (ProductsState) -> Void = { _ in }
    
    init(repository: ProductsRepositoryInterface, routing: Routing) {
        self.repository = repository
        self.routing = routing
    }
    
    func onStateChange(_ callback: @escaping (ProductsState) -> Void) {
        self.repository.onProductsChange { result in
            switch result {
            case .success:
                callback(.loaded)
                
            case .failure:
                callback(.error)
            }
        }
        
        self.callback = callback
    }
    
    func getProducts() {
        self.callback(.loading)
        self.repository.getProducts()
    }
    
    func getNumberOfProducts() -> Int {
        return self.repository.getNumberOfProducts()
    }
    
    func presentProductDetail(at index: Int) {
        guard let id = self.repository.getProductId(at: index) else {
            self.callback(.error)
            return
        }
        
        routing?.presentProductDetail(with: id)
    }
}
