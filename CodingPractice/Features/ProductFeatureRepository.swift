import Foundation

enum ProductsRepositoryState: Equatable {
    case updateAll
    case update(row: Int)
    case error
}

protocol ProductsRepositoryInterface {
    func onProductsChange(_ callback: @escaping (ProductsRepositoryState) -> Void)
    func getProducts()
    func getNumberOfProducts() -> Int
    func getProduct(at index: Int) -> Product?
}

protocol ProductDetailRepoitoryInterface {
    func getProduct(with id: String) -> Product?
    func toggleIsFavorited(with id: String)
}

final class ProductFeatureRepository {
    private let webService: WebService
    private let persistence: Persistence
    
    private var callback: (ProductsRepositoryState) -> Void = { _ in }
    
    init(webService: WebService, persistence: Persistence) {
        self.webService = webService
        self.persistence = persistence
    }
}

extension ProductFeatureRepository: ProductsRepositoryInterface {
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
                strongSelf.callback(.updateAll)
                
            case .failure:
                strongSelf.callback(.error)
            }
        }
    }
    
    func getNumberOfProducts() -> Int {
        return self.persistence.getNumberOfProducts()
    }
    
    func getProduct(at index: Int) -> Product? {
        return self.persistence.getProduct(at: index)
    }
}

extension ProductFeatureRepository: ProductDetailRepoitoryInterface {
    func getProduct(with id: String) -> Product? {
        return self.persistence.getProduct(with: id)
    }
    
    func toggleIsFavorited(with id: String) {
        self.persistence.toggleIsFavorited(with: id).map { index in
            self.callback(.update(row: index))
        }
    }
}
