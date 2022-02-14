import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let router = Router()
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windoScene = (scene as? UIWindowScene) else {
            return
        }
        
        let window = UIWindow(windowScene: windoScene)
        self.router.presentProducts(in: window)
        self.window = window
    }
}
