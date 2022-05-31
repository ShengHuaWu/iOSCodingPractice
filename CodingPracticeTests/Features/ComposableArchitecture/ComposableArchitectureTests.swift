import ComposableArchitecture
import XCTest

@testable import CodingPractice

extension WebServiceClientEnvironment {
    static let unimplemented = Self {
        .failing("getProducts has not been implemented")
    }
}

extension PersistenceEnvironment {
    static let unimplemented = Self { _ in
        .failing("storeProducts has not been implemented")
    }
}

private let fakeProducts: [Product] = [
    .init(
        id: "deedbeef-deed-beaf-deedbeefdeed",
        title: "Blob",
        description: "This is Blob",
        volume: 9
    )
]

private let webServiceError = WebServiceError(context: "getContext", reason: "Failure")

extension WebServiceClientEnvironment {
    static let success = Self {
        Effect(value: fakeProducts)
    }
    
    static let failure = Self {
        Effect(error: webServiceError)
    }
}

extension PersistenceEnvironment {
    static let success = Self(storeProducts: Effect.init(value:))
}

final class ComposableArchitectureTests: XCTestCase {
    private let scheduler = DispatchQueue.test
    
    func testFetchProductSuccess() {
        let store = TestStore(
            initialState: .init(),
            reducer: appReducer,
            environment: .init(
                webServiceClient: .success,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .success
            )
        )
        
        store.send(.fetchProducts)
        self.scheduler.advance()
        
        store.receive(.productsResponse(.success(fakeProducts))) {
            $0.productRows = fakeProducts.map(ProductRowDisplayInfo.init(product:))
        }
    }
    
    func testFetchProductFailure() {
        let store = TestStore(
            initialState: .init(),
            reducer: appReducer,
            environment: .init(
                webServiceClient: .failure,
                mainQueue: scheduler.eraseToAnyScheduler(),
                persistence: .unimplemented
            )
        )
        
        store.send(.fetchProducts)
        self.scheduler.advance()
        
        let appError = AppError(webServiceError: webServiceError)
        store.receive(.productsResponse(.failure(appError))) {
            $0.productRows = []
            $0.errorMessage = appError.description
        }
    }
}
