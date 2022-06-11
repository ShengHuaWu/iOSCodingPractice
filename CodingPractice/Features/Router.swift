import UIKit
import SwiftUI

protocol Routing: AnyObject {
    func presentProductDetail(with id: String)
}

final class Router {
    private weak var rootNavigationController: UINavigationController?
    
    private weak var repository: ProductFeatureRepository?
    
    func presentProducts(in window: UIWindow) {
        let webServiceClient = WebServiceClient(
            urlSession: .shared,
            dataProcessor: .init(jsonDecoder: .init())
        )
        let persistenceClient = PersistenceClient()
        
        let rootViewController: UIViewController
        if (ProcessInfo.processInfo.environment["enable_swift_ui"] != nil) {
            let environment = AppEnvironment.makeLive(
                webServiceClient: webServiceClient,
                persistenceClient: persistenceClient
            )
            let productListView = ProductListView(store: .init(
                initialState: .init(),
                reducer: appReducer.debug(),
                environment: environment
            ))
            rootViewController = UIHostingController(rootView: productListView)
        } else {
            let repository = ProductFeatureRepository(
                webService: webServiceClient,
                persistence: persistenceClient
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
