import ComposableArchitecture
import Foundation

// TODO: Split into product list state and product state
struct ProductListState: Equatable {
    var rows: [ProductRowDisplayInfo] = []
}

struct ProductDetailState: Equatable {
    var detail: ProductDetailDisplayInfo
}

struct AppState: Equatable {
    var productList: ProductListState
    var productDetail: ProductDetailState?
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
    case loadProductList
    case productListLoaded(Result<[Product], AppError>)
    case loadProduct(String)
    case productLoaded(Product)
    case toggleProductIsFavorite(String)
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
    case .loadProductList:
        state.productDetail = nil
        
        guard state.productList.rows.isEmpty else {
            return .none
        }
        
        return environment
            .webService
            .getProducts()
            .mapError(AppError.init(webServiceError:))
            .flatMap(environment.persistence.storeProducts)
            .receive(on: environment.mainQueue)
            .catchToEffect(AppAction.productListLoaded)
        
    case let .productListLoaded(.success(products)):
        state.productList.rows = products.map(ProductRowDisplayInfo.init(product:))
                
        return .none
        
    case let .productListLoaded(.failure(error)):
        state.errorMessage = error.description
        
        return .none
        
    case let .loadProduct(productId):
        return environment
            .persistence
            .getProduct(productId)
            .receive(on: environment.mainQueue)
            .flatMap(sendProductLoadedActionIfNeeded)
            .eraseToEffect()
        
    case let .productLoaded(product):
        let detail = ProductDetailDisplayInfo(product: product)
        state.productDetail = ProductDetailState(detail: detail)
        if let index = state.productList.rows.firstIndex(where: { $0.id == product.id }) {
            state.productList.rows.remove(at: index)
            state.productList.rows.insert(.init(product: product), at: index)
        }
        
        return .none
        
    case let .toggleProductIsFavorite(productId):
        return environment
            .persistence
            .toggleProductIsFavorited(productId)
            .receive(on: environment.mainQueue)
            .flatMap(sendProductLoadedActionIfNeeded)
            .eraseToEffect()
    }
}

private func sendProductLoadedActionIfNeeded(_ product: Product?) -> Effect<AppAction, Never> {
    guard let product = product else {
        return .none
    }
    
    return Effect(value: .productLoaded(product))
}
