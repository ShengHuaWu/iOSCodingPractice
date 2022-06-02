import Foundation

struct WebServiceError: Error, Equatable {
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
