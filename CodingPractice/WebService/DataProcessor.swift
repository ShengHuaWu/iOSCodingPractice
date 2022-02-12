import Foundation

final class DataProcessor {
    static func process<T>(data: Data?, response: URLResponse?, error: Error?) throws -> T where T: Decodable {
        if let anError = error {
            throw WebServiceClientError.makeGetProductsError(with: "network error: \(anError.localizedDescription)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw WebServiceClientError.makeGetProductsError(with: "invalid response: \(String(describing: response))")
        }
        
        guard let unwrappedData = data else {
            throw WebServiceClientError.makeGetProductsError(with: "empty response data")
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: unwrappedData)
        } catch {
            throw WebServiceClientError.makeGetProductsError(with: "parsing error: \(error.localizedDescription)")
        }
    }
}
