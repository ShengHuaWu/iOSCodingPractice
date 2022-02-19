struct Product: Decodable {
    // Ignore `isFavorited` during decoding
    enum CodingKeys: String, CodingKey {
        case id, title, description, volume
    }
    
    let id: String
    let title: String
    let description: String
    let volume: Int?
    
    var isFavorited: Bool = false
}

struct ProductsContainer: Decodable {
    let data: [Product]
}
