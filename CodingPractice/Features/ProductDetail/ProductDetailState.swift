struct ProductDetailDisplayInfo: Equatable {
    let title: String
    let description: String
    let isFavorited: Bool
}

enum ProductDetailState: Equatable {
    case present(ProductDetailDisplayInfo)
    case error
}
