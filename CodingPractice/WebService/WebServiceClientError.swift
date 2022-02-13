import Foundation

struct WebServiceClientError: Error {
    let context: String
    let reason: String
}

extension WebServiceClientError: CustomStringConvertible {
    var description: String {
        """
        \(context) failed with \(reason)
        """
    }
}
