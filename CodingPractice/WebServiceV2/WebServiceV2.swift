protocol WebServiceV2 {
    func getProducts() async throws -> [Product]
}

extension WebServiceClientV2: WebServiceV2 {}
