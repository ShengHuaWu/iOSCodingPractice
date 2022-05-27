import ComposableArchitecture
import Foundation

struct AppState: Equatable {
    var productRows: [ProductRowDisplayInfo]
}

enum AppAction {
    case fetchProducts
    case productsResponse(Result<[Product], WebServiceError>)
}

struct WebServiceClientEnvironment {
    var getProducts: () -> Effect<[Product], WebServiceError>
}

struct AppEnvironment {
    var webServiceClient: WebServiceClientEnvironment
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .fetchProducts:
        return environment
            .webServiceClient
            .getProducts()
            .receive(on: environment.mainQueue)
            .catchToEffect(AppAction.productsResponse)
        
    case let .productsResponse(.success(products)):
        return .none
        
    case let .productsResponse(.failure(error)):
        return .none
    }
}
