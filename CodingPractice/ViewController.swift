import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        WebServiceClient().getProducts { result in
            switch result {
            case let .success(products):
                print(products.count)
                
            case let .failure(error):
                print(error)
            }
        }
    }
}
