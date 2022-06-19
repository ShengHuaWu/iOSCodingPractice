import UIKit
import SwiftUI

protocol Routing: AnyObject {
    func presentProductDetail(with id: String)
}

final class Router {
    private weak var rootNavigationController: UINavigationController?
    
    private weak var repository: ProductFeatureRepository?
    
    func presentProducts(in window: UIWindow) {
        let rootViewController: UIViewController
        if (ProcessInfo.processInfo.environment["enable_swift_ui"] != nil) {
            let productListView = ProductListView(store: .init(
                initialState: .init(),
                reducer: productListReducer,
                environment: .live
            ))
            rootViewController = UIHostingController(rootView: productListView)
        } else {
            let webServiceClient = WebServiceClient(
                urlSession: .shared,
                dataProcessor: .init(jsonDecoder: .init())
            )
            let repository = ProductFeatureRepository(
                webService: webServiceClient,
                persistence: PersistenceClient()
            )
            self.repository = repository
            let viewModel = ProductsViewModel(
                repository: repository,
                routing: self
            )
            let viewController = ProductsViewController(viewModel: viewModel)
            let navigationController = UINavigationController(rootViewController: viewController)
            self.rootNavigationController = navigationController
            rootViewController = navigationController
        }
        
        window.rootViewController = rootViewController
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
