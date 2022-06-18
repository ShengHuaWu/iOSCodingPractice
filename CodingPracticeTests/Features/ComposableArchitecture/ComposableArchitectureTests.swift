import ComposableArchitecture
import XCTest

@testable import CodingPractice

extension WebServiceEnvironment {
    static let unimplemented = Self {
        .failing("getProducts has not been implemented")
    }
}

extension PersistenceEnvironment {
    static let unimplemented = Self(
        storeProducts: { _ in
            .failing("storeProducts has not been implemented")
        },
        getProduct: { _ in
            .failing("getProduct has not been implemented")
        },
        toggleProductIsFavorited: { _ in
            .failing("toggleProductIsFavorited has not been implemented")
        }
    )
}

private let fakeProduct = Product(
    id: "deedbeef-deed-beaf-deedbeefdeed",
    title: "Blob",
    description: "This is Blob",
    volume: 9
)

private let fakeProducts: [Product] = [fakeProduct]

private extension Product {
    func toggleIsFavorite() -> Self {
        var newProduct = self
        newProduct.isFavorited.toggle()
        
        return newProduct
    }
}

private let webServiceError = WebServiceError(context: "getContext", reason: "Failure")

extension WebServiceEnvironment {
    static let success = Self {
        Effect(value: fakeProducts)
    }
    
    static let failure = Self {
        Effect(error: webServiceError)
    }
}

extension PersistenceEnvironment {
    static let success = Self(
        storeProducts: Effect.init(value:),
        getProduct: { _ in
            Effect(value: fakeProduct)
        },
        toggleProductIsFavorited: { _ in
            Effect(value: fakeProduct.toggleIsFavorite())
        }
    )
}

final class ComposableArchitectureTests: XCTestCase {
    private let scheduler = DispatchQueue.test
    
    func testLoadProductListSuccess() {
        let store = TestStore(
            initialState: .init(
                productList: .init()
            ),
            reducer: appReducer,
            environment: .init(
                webService: .success,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .success
            )
        )
        
        store.send(.loadProductList)
        
        scheduler.advance()
        
        store.receive(.productListLoaded(.success(fakeProducts))) {
            $0.productList.rows = fakeProducts.map(ProductRowDisplayInfo.init(product:))
        }
    }
    
    func testLoadProductListFailure() {
        let store = TestStore(
            initialState: .init(
                productList: .init()
            ),
            reducer: appReducer,
            environment: .init(
                webService: .failure,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .unimplemented
            )
        )
        
        store.send(.loadProductList)
        scheduler.advance()
        
        let appError = AppError(webServiceError: webServiceError)
        store.receive(.productListLoaded(.failure(appError))) {
            $0.productList.rows = []
            $0.errorMessage = appError.description
        }
    }
    
    func testLoadProduct() {
        let store = TestStore(
            initialState: .init(
                productList: .init()
            ),
            reducer: appReducer,
            environment: .init(
                webService: .unimplemented,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .success
            )
        )
        
        store.send(.loadProduct("deedbeef-deed-beaf-deedbeefdeed"))
        scheduler.advance()
        
        store.receive(.productLoaded(fakeProduct)) {
            let detail = ProductDetailDisplayInfo(product: fakeProduct)
            $0.productDetail = .init(productId: fakeProduct.id, detail: detail)
        }
    }
    
    func testToggleProductIsFavorite() {
        let store = TestStore(
            initialState: .init(
                productList: .init(rows: fakeProducts.map(ProductRowDisplayInfo.init(product:)))
            ),
            reducer: appReducer,
            environment: .init(
                webService: .unimplemented,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .success
            )
        )
        
        store.send(.toggleProductIsFavorite("deedbeef-deed-beaf-deedbeefdeed"))
        scheduler.advance()
        
        store.receive(.productLoaded(fakeProduct.toggleIsFavorite())) {
            let detail = ProductDetailDisplayInfo(product: fakeProduct.toggleIsFavorite())
            $0.productDetail = .init(productId: fakeProduct.id, detail: detail)
            $0.productList.rows = [
                ProductRowDisplayInfo(product: fakeProduct.toggleIsFavorite())
            ]
        }
    }
}
