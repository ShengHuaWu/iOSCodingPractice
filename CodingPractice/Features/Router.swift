import UIKit

protocol Routing: AnyObject {
    func presentProductDetail(with id: String)
}

final class Router {
    private weak var rootNavigationController: UINavigationController?
    
    private weak var repository: ProductsRepository?
    
    func presentProducts(in window: UIWindow) {
        let webServiceClient = WebServiceClient(
            urlSession: .shared,
            dataProcessor: .init(jsonDecoder: .init())
        )
        let repository = ProductsRepository(webService: webServiceClient)
        self.repository = repository
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
    func presentProductDetail(with id: String) {
        guard let repository = self.repository else {
            return
        }
        
        let viewModel = ProductDetailViewModel(
            productId: id,
            repository: repository
        )
        let viewController = ProductDetailViewController(viewModel: viewModel)
        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }
}
