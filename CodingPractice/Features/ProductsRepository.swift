import Foundation

protocol ProductsRepositoryInterface {
    func onProductsChange(_ callback: @escaping (Result<[Product], Error>) -> Void)
    func getProducts()
    func getNumberOfProducts() -> Int
}

final class ProductsRepository {
    private let webService: WebService
    
    private var products: [Product] = []
    private var callback: (Result<[Product], Error>) -> Void = { _ in }
    
    init(webService: WebService) {
        self.webService = webService
    }
    
    func onProductsChange(_ callback: @escaping (Result<[Product], Error>) -> Void) {
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
                strongSelf.callback(.success(strongSelf.products))
                
            case let .failure(error):
                strongSelf.callback(.failure(error))
            }
        }
    }
    
    func getNumberOfProducts() -> Int {
        return self.products.count
    }
}

extension ProductsRepository: ProductsRepositoryInterface {}
