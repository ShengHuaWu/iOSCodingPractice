import Foundation

final class PersistenceClient {
    private var products: [Product] = []
    
    func store(_ products: [Product]) {
        self.products.append(contentsOf: products)
    }
    
    func getNumberOfProducts() -> Int {
        return self.products.count
    }
    
    func getProduct(at index: Int) -> Product? {
        guard index < self.products.count else {
            return nil
        }
        
        return self.products[index]
    }
    
    func getProduct(with id: String) -> Product? {
        return self.products.first(where: { $0.id == id })
    }
    
    func toggleIsFavorited(with id: String) -> Int? {
        guard let index = self.products.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        
        var product = self.products.remove(at: index)
        product.isFavorited.toggle()
        self.products.insert(product, at: index)
        
        return index
    }
}
