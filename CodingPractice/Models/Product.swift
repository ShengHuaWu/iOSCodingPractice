struct Product: Decodable {
    let id: String
    let title: String
    let description: String
    let volume: Int?
}

struct ProductsContainer: Decodable {
    let data: [Product]
}
