import Foundation

struct WebServiceError: Error {
    let context: String
    let reason: String
}

extension WebServiceError: CustomStringConvertible {
    var description: String {
        """
        \(context) failed with \(reason)
        """
    }
}
