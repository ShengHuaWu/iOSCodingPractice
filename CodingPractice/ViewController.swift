import UIKit

class ViewController: UIViewController {
    let webServiceClient = WebServiceClient(
        urlSession: .shared,
        dataProcessor: .init(jsonDecoder: .init())
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
