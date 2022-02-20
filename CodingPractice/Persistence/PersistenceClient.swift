import Foundation

final class PersistenceClient {
    private var products: [Product] = []
    
    func store(_ products: [Product]) {
        self.products.append(contentsOf: products)
    }
    
    func getProduct(with id: String) -> Product? {
        return self.products.first(where: { $0.id == id })
    }
    
    func toggleIsFavorited(with id: String) {
        guard let index = self.products.firstIndex(where: { $0.id == id }) else {
            return
        }
        
        var product = self.products.remove(at: index)
        product.isFavorited.toggle()
        self.products.insert(product, at: index)        
    }
}
