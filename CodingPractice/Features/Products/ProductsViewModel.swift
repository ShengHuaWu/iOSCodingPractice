import Foundation

final class ProductsViewModel {
    private let repository: ProductsRepository
    private weak var routing: Routing?
    
    private var callback: (ProductsState) -> Void = { _ in }
    
    init(repository: ProductsRepository, routing: Routing) {
        self.repository = repository
        self.routing = routing
    }
    
    func onStateChange(_ callback: @escaping (ProductsState) -> Void) {
        self.repository.onProductsChange { result in
            switch result {
            case let .updateAll(products):
                let productRows = products.map(ProductRowDisplayInfo.init(product:))
                callback(.loaded(productRows))
                
            case let .update(id, isFavorited):
                callback(.update(id: id, isFavorited: isFavorited))
                
            case .error:
                callback(.error)
            }
        }
        
        self.callback = callback
    }
    
    func getProducts() {
        self.callback(.loading)
        self.repository.getProducts()
    }
    
    func presentProductDetail(with id: String) {
        routing?.presentProductDetail(with: id)
    }
}
