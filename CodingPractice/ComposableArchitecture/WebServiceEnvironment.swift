import ComposableArchitecture
import Foundation

struct WebServiceEnvironment {
    var getProducts: () -> Effect<[Product], WebServiceError>
}

extension WebServiceEnvironment {
    static let live = Self {
        let urlStr = "https://api.gousto.co.uk/products/v2.0/products"
        let errorContext = "Get products"
                
        guard let url = URL(string: urlStr) else {
            let webServiceError = WebServiceError(
                context: errorContext,
                reason: "invalid url string: \(urlStr)"
            )
            
            return Effect(error: webServiceError)
        }
        
        return URLSession.shared
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
