import Foundation

final class ProductsViewModel {
    private let webService: WebService
    private var products: [Product] = []
    private var callback: () -> Void = {}
    
    init(webService: WebService) {
        self.webService = webService
    }
    
    func register(_ callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    func getProducts() {
        self.webService.getProducts { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case let .success(products):
                strongSelf.products = products
                
            case let .failure(error):
                print(error)
            }
            
            strongSelf.callback()
        }
    }
    
    func getNumberOfProducts() -> Int {
        return self.products.count
    }
}
