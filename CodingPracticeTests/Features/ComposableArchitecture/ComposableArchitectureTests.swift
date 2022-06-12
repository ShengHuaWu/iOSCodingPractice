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
    
    func testFetchProductSuccess() {
        let store = TestStore(
            initialState: .init(),
            reducer: appReducer,
            environment: .init(
                webService: .success,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .success
            )
        )
        
        store.send(.fetchProducts)
        scheduler.advance()
        
        store.receive(.productsResponse(.success(fakeProducts))) {
            $0.productRows = fakeProducts.map(ProductRowDisplayInfo.init(product:))
        }
    }
    
    func testFetchProductFailure() {
        let store = TestStore(
            initialState: .init(),
            reducer: appReducer,
            environment: .init(
                webService: .failure,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .unimplemented
            )
        )
        
        store.send(.fetchProducts)
        scheduler.advance()
        
        let appError = AppError(webServiceError: webServiceError)
        store.receive(.productsResponse(.failure(appError))) {
            $0.productRows = []
            $0.errorMessage = appError.description
        }
    }
    
    func testTapProductRow() {
        let store = TestStore(
            initialState: .init(),
            reducer: appReducer,
            environment: .init(
                webService: .unimplemented,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .success
            )
        )
        
        store.send(.tapProductRow("deedbeef-deed-beaf-deedbeefdeed"))
        scheduler.advance()
        
        store.receive(.presentProduct(fakeProduct)) {
            $0.productDetail = ProductDetailDisplayInfo(product: fakeProduct)
        }
    }
    
    func testTapProductIsFavorite() {
        let store = TestStore(
            initialState: .init(),
            reducer: appReducer,
            environment: .init(
                webService: .unimplemented,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .success
            )
        )
        
        store.send(.tapProductIsFavorite("deedbeef-deed-beaf-deedbeefdeed"))
        scheduler.advance()
        
        store.receive(.presentProduct(fakeProduct.toggleIsFavorite())) {
            $0.productDetail = ProductDetailDisplayInfo(product: fakeProduct.toggleIsFavorite())
        }
    }
}
