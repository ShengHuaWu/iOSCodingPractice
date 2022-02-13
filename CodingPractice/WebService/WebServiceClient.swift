import Foundation

final class WebServiceClient {
    private let urlSession: URLSession
    private let dataProcessor: DataProcessor
    
    init(urlSession: URLSession, dataProcessor: DataProcessor) {
        self.urlSession = urlSession
        self.dataProcessor = dataProcessor
    }
    
    func getProducts(_ completion: @escaping (Result<[Product], WebServiceError>) -> Void) {
        let urlStr = "https://api.gousto.co.uk/products/v2.0/products"
        let errorContext = "Get products"
                
        guard let url = URL(string: urlStr) else {
            let webServiceError = WebServiceError(
                context: errorContext,
                reason: "invalid url string: \(urlStr)"
            )
            completion(.failure(webServiceError))
            return
        }
        
        self.urlSession.dataTask(with: url) { [weak self] data, response, error in
            guard let strongSelf = self else {
                return
            }
            
            do {
                let container: ProductsContainer = try strongSelf.dataProcessor.process(
                    data: data,
                    response: response,
                    error: error,
                    errorContext: errorContext
                )
                completion(.success(container.data))
            } catch let error as WebServiceError {
                completion(.failure(error))
            } catch let error {
                let webServiceError = WebServiceError(
                    context: errorContext,
                    reason: "unexpected error: \(error.localizedDescription)"
                )
                completion(.failure(webServiceError))
            }
        }.resume()
    }
}
