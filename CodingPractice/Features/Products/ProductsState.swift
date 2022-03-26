enum ProductsState: Equatable {
    case loading
    case loaded([ProductRowDisplayInfo])
    case update(id: String, isFavorited: Bool)
    case error
}
