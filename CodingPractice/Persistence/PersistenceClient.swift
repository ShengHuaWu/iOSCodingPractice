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
    
    func getProduct(with id: String) -> Product? {
        return self.queue.sync { [weak self] in
            return self?.products.first(where: { $0.id == id })
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
}
