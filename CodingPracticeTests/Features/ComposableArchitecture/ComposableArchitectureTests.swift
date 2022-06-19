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
}
