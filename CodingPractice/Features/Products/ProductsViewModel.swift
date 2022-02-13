import Foundation

final class ProductsViewModel {
    private let webService: WebService
    private var products: [Product] = []
    private var callback: (ProductsState) -> Void = { _ in }
    
    init(webService: WebService) {
        self.webService = webService
    }
    
    func onStateChange(_ callback: @escaping (ProductsState) -> Void) {
        self.callback = callback
    }
    
    func getProducts() {
        self.callback(.loading)
        self.webService.getProducts { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case let .success(products):
                strongSelf.products = products
                strongSelf.callback(.loaded)
                
            case .failure:
                strongSelf.callback(.error)
            }
        }
    }
    
    func getNumberOfProducts() -> Int {
        return self.products.count
    }
}
