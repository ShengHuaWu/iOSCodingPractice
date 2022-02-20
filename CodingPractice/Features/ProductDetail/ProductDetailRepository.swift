protocol ProductDetailRepoitory {
    func getProduct(with id: String) -> Product?
    func toggleIsFavorited(with id: String)
}
