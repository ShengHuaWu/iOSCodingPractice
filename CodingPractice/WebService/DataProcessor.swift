import Foundation

final class DataProcessor {
    private let jsonDecoder: JSONDecoder
    
    init(jsonDecoder: JSONDecoder) {
        self.jsonDecoder = jsonDecoder
    }
    
    func process<T>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        errorContext: String
    ) throws -> T where T: Decodable {
        if let anError = error {
            throw WebServiceClientError(
                context: errorContext,
                reason: "network error: \(anError.localizedDescription)"
            )
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw WebServiceClientError(
                context: errorContext,
                reason: "invalid response: \(String(describing: response))"
            )
        }
        
        guard let unwrappedData = data else {
            throw WebServiceClientError(
                context: errorContext,
                reason: "empty response data"
            )
        }
        
        do {
            return try self.jsonDecoder.decode(T.self, from: unwrappedData)
        } catch {
            throw WebServiceClientError(
                context: errorContext,
                reason: "parsing error: \(error.localizedDescription)"
            )
        }
    }
}
