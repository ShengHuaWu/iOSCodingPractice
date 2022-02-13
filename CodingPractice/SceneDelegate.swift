import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windoScene = (scene as? UIWindowScene) else {
            return
        }
        
        let webServiceClient = WebServiceClient(
            urlSession: .shared,
            dataProcessor: .init(jsonDecoder: .init())
        )
        let productsViewModel = ProductsViewModel(webService: webServiceClient)
        let productsViewController = ProductsViewController(viewModel: productsViewModel)
        let navigationController = UINavigationController(rootViewController: productsViewController)
        
        self.window = UIWindow(windowScene: windoScene)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
}
