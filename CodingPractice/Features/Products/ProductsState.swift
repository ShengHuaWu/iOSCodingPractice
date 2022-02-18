struct ProductRowDisplayInfo {
    let title: String
    let isFavorited: Bool
}

enum ProductsState: Equatable {
    case loading
    case loaded
    case error
}
