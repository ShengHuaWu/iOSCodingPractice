import ComposableArchitecture
import XCTest

@testable import CodingPractice

extension WebServiceClientEnvironment {
    static let failing = Self {
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

extension WebServiceClientEnvironment {
    static let success = Self {
        Effect(value: fakeProducts)
    }
}

final class ComposableArchitectureTests: XCTestCase {
    private let scheduler = DispatchQueue.test
    
    func testFetchProduct() {
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
        store.receive(.productsResponse(.success(fakeProducts)))
    }
}
