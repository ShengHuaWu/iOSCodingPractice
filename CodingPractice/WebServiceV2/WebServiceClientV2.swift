import Foundation

final class WebServiceClientV2 {
    private let urlSession: URLSession
    private let dataProcessor: DataProcessor
    
    init(urlSession: URLSession, dataProcessor: DataProcessor) {
        self.urlSession = urlSession
        self.dataProcessor = dataProcessor
    }
    
    func getProducts() async throws -> [Product] {
        let urlStr = "https://api.gousto.co.uk/products/v2.0/products"
        let errorContext = "Get products"
                
        guard let url = URL(string: urlStr) else {
            let webServiceError = WebServiceError(
                context: errorContext,
                reason: "invalid url string: \(urlStr)"
            )
            throw webServiceError
        }
        
        let (data, response) = try await urlSession.data(from: url)
        let entity: ProductsContainer = try dataProcessor.process(
            data: data,
            response: response,
            error: nil,
            errorContext: errorContext
        )
        
        return entity.data
    }
}
