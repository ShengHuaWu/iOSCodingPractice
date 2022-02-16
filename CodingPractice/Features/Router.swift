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
        let repository = ProductsRepository(webService: webServiceClient)
        let viewModel = ProductsViewModel(
            repository: repository,
            routing: self
        )
        let viewController = ProductsViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        self.rootNavigationController = navigationController
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

extension Router: Routing {
    func presentProductDetail() {
        let viewController = ProductDetailViewController()
        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }
}
