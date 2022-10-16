import Foundation

protocol DataProcessorService: AnyObject {
    func process<T>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        errorContext: String
    ) throws -> T where T: Decodable
}

final class DataProcessor: DataProcessorService {
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
            throw WebServiceError(
                context: errorContext,
                reason: "network error: \(anError.localizedDescription)"
            )
        }
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw WebServiceError(
                context: errorContext,
                reason: "invalid response: \(String(describing: response))"
            )
        }
        
        guard let unwrappedData = data else {
            throw WebServiceError(
                context: errorContext,
                reason: "empty response data"
            )
        }
        
        do {
            return try self.jsonDecoder.decode(T.self, from: unwrappedData)
        } catch {
            throw WebServiceError(
                context: errorContext,
                reason: "parsing error: \(error.localizedDescription)"
            )
        }
    }
}
