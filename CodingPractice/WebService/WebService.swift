import Foundation

protocol WebService {
    func getProducts(_ completion: @escaping (Result<[Product], WebServiceError>) -> Void)
}

extension WebServiceClient: WebService {}
