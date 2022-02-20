protocol Persistence {
    func store(_ products: [Product])
    func getNumberOfProducts() -> Int
    func getProduct(at index: Int) -> Product?
    func getProduct(with id: String) -> Product?
    func toggleIsFavorited(with id: String) -> Int? // TODO: Re-visit this method
}

extension PersistenceClient: Persistence {}
