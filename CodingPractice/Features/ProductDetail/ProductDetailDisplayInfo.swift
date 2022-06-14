struct ProductDetailDisplayInfo: Equatable, Hashable {
    let id: String
    let title: String
    let description: String
    let isFavorited: Bool
}

extension ProductDetailDisplayInfo {
    init(product: Product) {
        self.id = product.id
        self.title = product.title
        self.description = product.description
        self.isFavorited = product.isFavorited
    }
}
