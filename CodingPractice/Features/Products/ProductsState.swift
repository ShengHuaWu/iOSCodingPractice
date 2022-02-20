enum ProductsState: Equatable {
    case loading
    case loaded
    case update(row: Int)
    case error
}
