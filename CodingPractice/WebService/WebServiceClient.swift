import ComposableArchitecture
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
        
        self.perform(.init(url: url), errorContext: errorContext) { (result: Result<ProductsContainer, WebServiceError>) in
            completion(result.map { $0.data })
        }
    }
    
    func getProducts() -> Effect<[Product], WebServiceError> {
        let urlStr = "https://api.gousto.co.uk/products/v2.0/products"
        let errorContext = "Get products"
                
        guard let url = URL(string: urlStr) else {
            let webServiceError = WebServiceError(
                context: errorContext,
                reason: "invalid url string: \(urlStr)"
            )
            
            return Effect(error: webServiceError)
        }
        
        return self.urlSession
            .dataTaskPublisher(for: .init(url: url))
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    throw WebServiceError(
                        context: errorContext,
                        reason: "invalid response: \(String(describing: response))"
                    )
                }
                
                return data
            }
            .decode(type: ProductsContainer.self, decoder: JSONDecoder())
            .map(\.data)
            .mapError { error in
                if let webServiceError = error as? WebServiceError {
                    return webServiceError
                }
                
                let webServiceError = WebServiceError(
                    context: errorContext,
                    reason: "unexpected error: \(error.localizedDescription)"
                )
                
                return webServiceError
            }
            .eraseToEffect()
    }
}

// MARK: - Private
private extension WebServiceClient {
    func perform<Entity>(
        _ request: URLRequest,
        errorContext: String,
        _ completion: @escaping (Result<Entity, WebServiceError>) -> Void
    ) where Entity: Decodable {
        self.urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let strongSelf = self else {
                return
            }
            
            do {
                let entity: Entity = try strongSelf.dataProcessor.process(
                    data: data,
                    response: response,
                    error: error,
                    errorContext: errorContext
                )
                completion(.success(entity))
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
