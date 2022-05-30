import ComposableArchitecture
import XCTest

@testable import CodingPractice

extension WebServiceClientEnvironment {
    static let unimplemented = Self {
        .failing("getProducts has not been implemented")
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

final class ComposableArchitectureTests: XCTestCase {
    private let scheduler = DispatchQueue.test
    
    func testFetchProductSuccess() {
        let store = TestStore(
            initialState: .init(),
            reducer: appReducer,
            environment: .init(
                webServiceClient: .success,
                mainQueue: scheduler.eraseToAnyScheduler()
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
                mainQueue: scheduler.eraseToAnyScheduler()
            )
        )
        
        store.send(.fetchProducts)
        self.scheduler.advance()
        
        store.receive(.productsResponse(.failure(webServiceError))) {
            $0.productRows = []
            $0.errorMessage = webServiceError.description
        }
    }
}
