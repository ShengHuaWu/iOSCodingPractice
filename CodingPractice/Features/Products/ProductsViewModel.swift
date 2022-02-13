import Foundation

final class ProductsViewModel {
    private let webServiceClient: WebServiceClient
    private var products: [Product] = []
    private var callback: () -> Void = {}
    
    init(webServiceClient: WebServiceClient) {
        self.webServiceClient = webServiceClient
    }
    
    func register(_ callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    func getProducts() {
        self.webServiceClient.getProducts { [weak self] result in
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
