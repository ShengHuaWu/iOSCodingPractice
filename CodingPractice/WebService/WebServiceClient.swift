import Foundation

final class WebServiceClient {
    func getProducts(_ completion: @escaping (Result<[Product], WebServiceClientError>) -> Void) {
        let urlStr = "https://api.gousto.co.uk/products/v2.0/products"
                
        guard let url = URL(string: urlStr) else {
            completion(.failure(.makeGetProductsError(with: "invalid url string: \(urlStr)")))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            do {
                let container: ProductsContainer = try DataProcessor.process(data: data, response: response, error: error)
                completion(.success(container.data))
            } catch let error as WebServiceClientError {
                completion(.failure(error))
            } catch let error {
                completion(.failure(.makeGetProductsError(with: "unexpected error: \(error.localizedDescription)")))
            }
        }.resume()
    }
}
