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

// TODO: Re-name actions to app features
enum AppAction: Equatable {
    case fetchProducts
    case productsResponse(Result<[Product], AppError>)
    case tapProductRow(String)
    case presentProduct(Product)
    case tapProductIsFavorite(String)
}

struct AppEnvironment {
    var webService: WebServiceEnvironment
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var persistence: PersistenceEnvironment
}

extension AppEnvironment {
    static let live = Self(
        webService: .live,
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        persistence: .live
    )
}

#if DEBUG
private let productsForPreview = [
    Product(id: "ABC", title: "Fake Product 1", description: "Blob blob blob", volume: 5),
    .init(id: "EDF", title: "Fake Product 2", description: "This is the fake product 2", volume: 9, isFavorited: true),
    .init(id: "XYZ", title: "What the hell", description: "Nothing to say", volume: 8)
]

extension WebServiceEnvironment {
    static let preview = Self {
        Effect(value: productsForPreview)
    }
}

extension PersistenceEnvironment {
    static let preview = Self(
        storeProducts: { Effect(value: $0) },
        getProduct: { _ in Effect(value: productsForPreview.first) },
        toggleProductIsFavorited: { _ in Effect(value: productsForPreview.first) }
    )
}

extension AppEnvironment {
    static let preview = Self(
        webService: .preview,
        mainQueue: .immediate,
        persistence: .preview
    )
}
#endif

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .fetchProducts:
        state.productDetail = nil
        
        guard state.productRows.isEmpty else {
            return .none
        }
        
        return environment
            .webService
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
            .flatMap(sendPresentProductActionIfNeeded)
            .eraseToEffect()
        
    case let .presentProduct(product):
        state.productDetail = ProductDetailDisplayInfo(product: product)
        if let index = state.productRows.firstIndex(where: { $0.id == product.id }) {
            state.productRows.remove(at: index)
            state.productRows.insert(.init(product: product), at: index)
        }
        
        return .none
        
    case let .tapProductIsFavorite(productId):
        return environment
            .persistence
            .toggleProductIsFavorited(productId)
            .receive(on: environment.mainQueue)
            .flatMap(sendPresentProductActionIfNeeded)
            .eraseToEffect()
    }
}

private func sendPresentProductActionIfNeeded(_ product: Product?) -> Effect<AppAction, Never> {
    guard let product = product else {
        return .none
    }
    
    return Effect(value: .presentProduct(product))
}
