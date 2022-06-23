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
    
    func testLoadListSuccess() {
        let store = TestStore(
            initialState: .init(),
            reducer: productListReducer,
            environment: .init(
                webService: .success,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .success
            )
        )
        
        store.send(.loadList)
        scheduler.advance()
        
        store.receive(.listLoaded(.success(fakeProducts))) {
            $0.rows = fakeProducts.map(ProductRowDisplayInfo.init(product:))
        }
    }
    
    func testLoadListFailure() {
        let store = TestStore(
            initialState: .init(),
            reducer: productListReducer,
            environment: .init(
                webService: .failure,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .success
            )
        )
        
        store.send(.loadList)
        scheduler.advance()
        
        store.receive(.listLoaded(.failure(.init(webServiceError: webServiceError)))) {
            $0.errorMessage = webServiceError.description
        }
    }
    
    func testSetNavigationSelection() {
        let store = TestStore(
            initialState: .init(
                rows: fakeProducts.map(ProductRowDisplayInfo.init(product:))
            ),
            reducer: productListReducer,
            environment: .init(
                webService: .success,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .success
            )
        )
        
        store.send(.setNavigation(fakeProduct.id)) {
            $0.selection = .init(.init(productId: fakeProduct.id), id: fakeProduct.id)
        }
    }
    
    func testLoadDetail() {
        let store = TestStore(
            initialState: .init(
                rows: fakeProducts.map(ProductRowDisplayInfo.init(product:))
            ),
            reducer: productListReducer,
            environment: .init(
                webService: .success,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .success
            )
        )
        
        store.send(.setNavigation(fakeProduct.id)) {
            $0.selection = .init(.init(productId: fakeProduct.id), id: fakeProduct.id)
        }
        
        store.send(.detail(.loadDetail(fakeProduct.id)))
        scheduler.advance()
        
        store.receive(.detail(.detailLoaded(fakeProduct))) {
            $0.selection = .init(
                .init(
                    productId: fakeProduct.id,
                    detail: .init(product: fakeProduct)
                ),
                id: fakeProduct.id
            )
        }
    }
    
    func testToggleIsProductFavorited() {
        let store = TestStore(
            initialState: .init(
                rows: fakeProducts.map(ProductRowDisplayInfo.init(product:))
            ),
            reducer: productListReducer,
            environment: .init(
                webService: .success,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .success
            )
        )
        
        store.send(.setNavigation(fakeProduct.id)) {
            $0.selection = .init(.init(productId: fakeProduct.id), id: fakeProduct.id)
        }
        
        store.send(.detail(.loadDetail(fakeProduct.id)))
        scheduler.advance()
        
        store.receive(.detail(.detailLoaded(fakeProduct))) {
            $0.selection = .init(
                .init(
                    productId: fakeProduct.id,
                    detail: .init(product: fakeProduct)
                ),
                id: fakeProduct.id
            )
        }
        
        store.send(.detail(.toggleProductIsFavorite(fakeProduct.id)))
        scheduler.advance()
        
        store.receive(.detail(.detailLoaded(fakeProduct.toggleIsFavorite()))) {
            $0.rows = [ProductRowDisplayInfo(product: fakeProduct.toggleIsFavorite())]
            $0.selection = .init(
                .init(
                    productId: fakeProduct.id,
                    detail: .init(product: fakeProduct.toggleIsFavorite())
                ),
                id: fakeProduct.id
            )
        }
    }
}
