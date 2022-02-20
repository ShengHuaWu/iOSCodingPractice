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
    
    private var products: [Product] = []
    private var callback: (ProductsRepositoryState) -> Void = { _ in }
    
    init(webService: WebService) {
        self.webService = webService
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
                strongSelf.products.append(contentsOf: products)
                strongSelf.callback(.updateAll)
                
            case .failure:
                strongSelf.callback(.error)
            }
        }
    }
    
    func getNumberOfProducts() -> Int {
        return self.products.count
    }
    
    func getProduct(at index: Int) -> Product? {
        guard index < self.products.count else {
            return nil
        }
        
        return self.products[index]
    }
}

extension ProductFeatureRepository: ProductDetailRepoitoryInterface {
    func getProduct(with id: String) -> Product? {
        return self.products.first(where: { $0.id == id })
    }
    
    func toggleIsFavorited(with id: String) {
        guard let index = self.products.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        var product = self.products.remove(at: index)
        product.isFavorited.toggle()
        self.products.insert(product, at: index)
        
        self.callback(.update(row: index))
    }
}
