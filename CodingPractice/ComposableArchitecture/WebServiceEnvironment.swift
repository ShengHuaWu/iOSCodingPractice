import ComposableArchitecture
import Foundation

struct WebServiceEnvironment {
    var getProducts: () -> Effect<[Product], WebServiceError>
}

extension WebServiceEnvironment {
    static func makeLive(webServiceClient: WebServiceClient) -> Self {
        return .init {
            webServiceClient.getProducts()
        }
    }
}
