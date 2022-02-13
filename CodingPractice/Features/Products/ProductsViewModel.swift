import Foundation

final class ProductsViewModel {
    private let webServiceClient: WebServiceClient
    
    init(webServiceClient: WebServiceClient) {
        self.webServiceClient = webServiceClient
    }
    
    func getProducts() {
        self.webServiceClient.getProducts { result in
            switch result {
            case let .success(products):
                print(products.count)
                
            case let .failure(error):
                print(error)
            }
        }
    }
}
