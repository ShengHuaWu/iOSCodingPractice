import UIKit

final class Router {
    func presentProducts(in window: UIWindow) {
        let webServiceClient = WebServiceClient(
            urlSession: .shared,
            dataProcessor: .init(jsonDecoder: .init())
        )
        let productsViewModel = ProductsViewModel(webService: webServiceClient)
        let productsViewController = ProductsViewController(viewModel: productsViewModel)
        let navigationController = UINavigationController(rootViewController: productsViewController)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
