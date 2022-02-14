import UIKit

protocol Routing: AnyObject {
    func presentProductDetail()
}

final class Router {
    private weak var rootNavigationController: UINavigationController?
    
    func presentProducts(in window: UIWindow) {
        let webServiceClient = WebServiceClient(
            urlSession: .shared,
            dataProcessor: .init(jsonDecoder: .init())
        )
        let productsViewModel = ProductsViewModel(
            webService: webServiceClient,
            routing: self
        )
        let productsViewController = ProductsViewController(viewModel: productsViewModel)
        let navigationController = UINavigationController(rootViewController: productsViewController)
        self.rootNavigationController = navigationController
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

extension Router: Routing {
    func presentProductDetail() {
        let productDetailViewController = ProductDetailViewController()
        self.rootNavigationController?.pushViewController(productDetailViewController, animated: true)
    }
}
