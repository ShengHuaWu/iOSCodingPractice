struct ProductRowDisplayInfo: Equatable, Identifiable {
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
