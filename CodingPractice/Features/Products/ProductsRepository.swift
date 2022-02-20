enum ProductsRepositoryState: Equatable {
    case updateAll([Product])
    case update(id: String)
    case error
}

protocol ProductsRepository {
    func onProductsChange(_ callback: @escaping (ProductsRepositoryState) -> Void)
    func getProducts()
}
