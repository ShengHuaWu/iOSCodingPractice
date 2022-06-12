import ComposableArchitecture
import Foundation

struct AppState: Equatable {
    var productRows: [ProductRowDisplayInfo] = []
    var productDetail: ProductDetailDisplayInfo?
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
    case tapProductRow(String)
    case presentProduct(Product)
    case tapProductIsFavorite(String)
}

// TODO: Re-name XXXEnvironment
struct WebServiceClientEnvironment {
    var getProducts: () -> Effect<[Product], WebServiceError>
}

struct PersistenceEnvironment {
    var storeProducts: ([Product]) -> Effect<[Product], Never>
    var getProduct: (String) -> Effect<Product?, Never>
    var toggleProductIsFavorited: (String) -> Effect<Product?, Never>
}

struct AppEnvironment {
    var webServiceClient: WebServiceClientEnvironment
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var persistence: PersistenceEnvironment
}

extension WebServiceClientEnvironment {
    static func makeLive(webServiceClient: WebServiceClient) -> Self {
        return .init {
            webServiceClient.getProducts()
        }
    }
}

extension PersistenceEnvironment {
    static func makeLive(persistenceClient: PersistenceClient) -> Self {
        return .init(
            storeProducts: { products in
                persistenceClient.store(products: products)
            },
            getProduct: { id in
                persistenceClient.getProduct(id: id)
            },
            toggleProductIsFavorited: { id in
                persistenceClient.toggleIsFavorited(id: id)
            }
        )
    }
}

extension AppEnvironment {
    static func makeLive(
        webServiceClient: WebServiceClient,
        persistenceClient: PersistenceClient
    ) -> Self {
        .init(
            webServiceClient: .makeLive(webServiceClient: webServiceClient),
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            persistence: .makeLive(persistenceClient: persistenceClient)
        )
    }
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
        
    case let .tapProductRow(productId):
        return environment
            .persistence
            .getProduct(productId)
            .receive(on: environment.mainQueue)
            .flatMap { product -> Effect<AppAction, Never> in
                guard let product = product else {
                    return .none
                }
                
                return Effect(value: AppAction.presentProduct(product))
            }
            .eraseToEffect()
        
    case let .presentProduct(product):
        state.productDetail = ProductDetailDisplayInfo(product: product)
        
        return .none
        
    case let .tapProductIsFavorite(productId):
        return environment
            .persistence
            .toggleProductIsFavorited(productId)
            .receive(on: environment.mainQueue)
            .flatMap { product -> Effect<AppAction, Never> in
                guard let product = product else {
                    return .none
                }
                
                return Effect(value: AppAction.presentProduct(product))
            }
            .eraseToEffect()
    }
}
