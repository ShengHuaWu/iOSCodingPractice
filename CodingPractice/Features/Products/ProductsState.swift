struct ProductRowDisplayInfo {
    let id: String
    let title: String
    let isFavorited: Bool
}

extension ProductRowDisplayInfo {
    init(product: Product) {
        self.id = product.id
        self.title = product.title
        self.isFavorited = product.isFavorited
    }
}

enum ProductsState: Equatable {
    case loading
    case loaded
    case update(row: Int)
    case error
}
