import ComposableArchitecture
import Foundation

struct PersistenceEnvironment {
    var storeProducts: ([Product]) -> Effect<[Product], Never>
    var getProduct: (String) -> Effect<Product?, Never>
    var toggleProductIsFavorited: (String) -> Effect<Product?, Never>
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
