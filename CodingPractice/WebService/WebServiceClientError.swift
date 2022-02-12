import Foundation

struct WebServiceClientError: Error {
    let context: String
    let reason: String
}

extension WebServiceClientError {
    static func makeGetProductsError(with reason: String) -> Self {
        .init(context: "Get products", reason: reason)
    }
}

extension WebServiceClientError: CustomStringConvertible {
    var description: String {
        """
        \(context) failed with \(reason)
        """
    }
}
