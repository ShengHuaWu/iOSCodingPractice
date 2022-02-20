import Foundation

final class ProductFeatureRepository {
    private let webService: WebService
    private let persistence: Persistence
    
    private var callback: (ProductsRepositoryState) -> Void = { _ in }
    
    init(webService: WebService, persistence: Persistence) {
        self.webService = webService
        self.persistence = persistence
    }
}

extension ProductFeatureRepository: ProductsRepository {
    func onProductsChange(_ callback: @escaping (ProductsRepositoryState) -> Void) {
        self.callback = callback
    }
    
    func getProducts() {
        self.webService.getProducts { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case let .success(products):
                strongSelf.persistence.store(products)
                strongSelf.callback(.updateAll(products))
                
            case .failure:
                strongSelf.callback(.error)
            }
        }
    }
}

extension ProductFeatureRepository: ProductDetailRepoitory {
    func getProduct(with id: String) -> Product? {
        return self.persistence.getProduct(with: id)
    }
    
    func toggleIsFavorited(with id: String) {
        self.persistence.toggleIsFavorited(with: id)
        self.callback(.update(id: id))
    }
}
