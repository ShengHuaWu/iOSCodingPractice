import ComposableArchitecture
import Foundation

final class PersistenceClient {
    private var products: [Product] = []
    private let queue: DispatchQueue // Use a serial queue to protect reading & writing operations
    
    init(queue: DispatchQueue = .init(label: "PersistenceClient")) {
        self.queue = queue
    }
    
    func store(_ products: [Product]) {
        self.queue.sync { [weak self] in
            self?.products.append(contentsOf: products)
        }
    }
    
    func store(products: [Product]) -> Effect<[Product], Never> {
        return self.queue.sync { [weak self] in
            self?.products.append(contentsOf: products)
            
            return Effect(value: products)
        }
    }
    
    func getProduct(with id: String) -> Product? {
        return self.queue.sync { [weak self] in
            return self?.products.first(where: { $0.id == id })
        }
    }
    
    func getProduct(id: String) -> Effect<Product?, Never> {
        return self.queue.sync { [weak self] in
            let product = self?.products.first(where: { $0.id == id })
            
            return Effect(value: product)
        }
    }
    
    func toggleIsFavorited(with id: String) -> Bool {
        self.queue.sync { [weak self] in
            guard let strongSelf = self else {
                return false
            }
            
            guard let index = strongSelf.products.firstIndex(where: { $0.id == id }) else {
                return false
            }
            
            var product = strongSelf.products.remove(at: index)
            product.isFavorited.toggle()
            strongSelf.products.insert(product, at: index)
            
            return product.isFavorited
        }
    }
    
    func toggleIsFavorited(id: String) -> Effect<Product?, Never> {
        return self.queue.sync { [weak self] in
            guard let strongSelf = self,
                  let index = strongSelf.products.firstIndex(where: { $0.id == id }) else {
                return Effect(value: nil)
            }
            
            var product = strongSelf.products.remove(at: index)
            product.isFavorited.toggle()
            strongSelf.products.insert(product, at: index)
            
            return Effect(value: product)
        }
    }
}
