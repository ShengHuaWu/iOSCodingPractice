import ComposableArchitecture
import Foundation

struct PersistenceEnvironment {
    var storeProducts: ([Product]) -> Effect<[Product], Never>
    var getProduct: (String) -> Effect<Product?, Never>
    var toggleProductIsFavorited: (String) -> Effect<Product?, Never>
}

private var storedProducts: [Product] = []

// Use a serial queue to protect reading & writing operations
private let queue = DispatchQueue(label: "PersistenceEnvironment")

extension PersistenceEnvironment {
    static let live = Self(
        storeProducts: { products in
            queue.sync {
                storedProducts.append(contentsOf: products)
                
                return Effect(value: products)
            }
        },
        getProduct: { id in
            queue.sync {
                let product = storedProducts.first(where: { $0.id == id })
                
                return Effect(value: product)
            }
        },
        toggleProductIsFavorited: { id in
            queue.sync {
                guard let index = storedProducts.firstIndex(where: { $0.id == id }) else {
                    return Effect(value: nil)
                }
                
                var product = storedProducts.remove(at: index)
                product.isFavorited.toggle()
                storedProducts.insert(product, at: index)
                
                return Effect(value: product)
            }
        }
    )
}
