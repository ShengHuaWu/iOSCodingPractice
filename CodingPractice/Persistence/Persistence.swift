protocol Persistence {
    func store(_ products: [Product])
    func getProduct(with id: String) -> Product?
    func toggleIsFavorited(with id: String) -> Bool
}

extension PersistenceClient: Persistence {}
