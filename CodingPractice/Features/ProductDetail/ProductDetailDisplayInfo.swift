struct ProductDetailDisplayInfo: Equatable, Hashable {
    let title: String
    let description: String
    let isFavorited: Bool
}

extension ProductDetailDisplayInfo {
    init(product: Product) {
        self.title = product.title
        self.description = product.description
        self.isFavorited = product.isFavorited
    }
}
