import ComposableArchitecture
import Foundation

struct AppState: Equatable {
    var productRows: [ProductRowDisplayInfo] = []
    var errorMessage: String = ""
}

struct AppError: Error, Equatable {
    let context: String
    let reason: String
}

extension AppError: CustomStringConvertible {
    var description: String {
        """
        \(context) failed with \(reason)
        """
    }
}

extension AppError {
    init(webServiceError: WebServiceError) {
        self.context = webServiceError.context
        self.reason = webServiceError.reason
    }
}

enum AppAction: Equatable {
    case fetchProducts
    case productsResponse(Result<[Product], AppError>)
}

// TODO: Re-name XXXEnvironment
struct WebServiceClientEnvironment {
    var getProducts: () -> Effect<[Product], WebServiceError>
}

struct PersistenceEnvironment {
    var storeProducts: ([Product]) -> Effect<[Product], Never>
}

struct AppEnvironment {
    var webServiceClient: WebServiceClientEnvironment
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var persistence: PersistenceEnvironment
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .fetchProducts:
        return environment
            .webServiceClient
            .getProducts()
            .mapError(AppError.init(webServiceError:))
            .flatMap(environment.persistence.storeProducts)
            .receive(on: environment.mainQueue)
            .catchToEffect(AppAction.productsResponse)
        
    case let .productsResponse(.success(products)):
        state.productRows = products.map(ProductRowDisplayInfo.init(product:))
                
        return .none
        
    case let .productsResponse(.failure(error)):
        state.errorMessage = error.description
        
        return .none
    }
}
