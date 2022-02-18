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
    
    func getProductRow(at index: Int) -> ProductRowDisplayInfo {
        guard let product = self.repository.getProduct(at: index) else {
            self.callback(.error)
            
            return .init(
                title: "placeholder title",
                isFavorited: false
            )
        }
        
        return .init(
            title: product.title,
            isFavorited: false
        )
    }
    
    func presentProductDetail(at index: Int) {
        guard let id = self.repository.getProductId(at: index) else {
            self.callback(.error)
            return
        }
        
        routing?.presentProductDetail(with: id)
    }
}
