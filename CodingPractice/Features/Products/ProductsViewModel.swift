import Foundation

final class ProductsViewModel {
    private let webService: WebService
    private weak var routing: Routing?
    
    private var products: [Product] = []
    private var callback: (ProductsState) -> Void = { _ in }
    
    init(webService: WebService, routing: Routing) {
        self.webService = webService
        self.routing = routing
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
    
    func presentProductDetail(at index: Int) {
        routing?.presentProductDetail()
    }
}
