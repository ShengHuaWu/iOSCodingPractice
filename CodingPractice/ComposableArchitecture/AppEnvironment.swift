import ComposableArchitecture
import Foundation

struct AppError: Error, Equatable {
    let context: String
    let reason: String
}

extension AppError: CustomStringConvertible {
    var description: String {
        """
        \(context) failed with \(reason)
        """
    }
}

extension AppError {
    init(webServiceError: WebServiceError) {
        self.context = webServiceError.context
        self.reason = webServiceError.reason
    }
}

struct AppEnvironment {
    var webService: WebServiceEnvironment
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var persistence: PersistenceEnvironment
}

extension AppEnvironment {
    static let live = Self(
        webService: .live,
        mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
        persistence: .live
    )
}

#if DEBUG
private let productsForPreview = [
    Product(id: "ABC", title: "Fake Product 1", description: "Blob blob blob", volume: 5),
    .init(id: "EDF", title: "Fake Product 2", description: "This is the fake product 2", volume: 9, isFavorited: true),
    .init(id: "XYZ", title: "What the hell", description: "Nothing to say", volume: 8)
]

extension WebServiceEnvironment {
    static let preview = Self {
        Effect(value: productsForPreview)
    }
}

extension PersistenceEnvironment {
    static let preview = Self(
        storeProducts: { Effect(value: $0) },
        getProduct: { _ in Effect(value: productsForPreview.first) },
        toggleProductIsFavorited: { _ in Effect(value: productsForPreview.first) }
    )
}

extension AppEnvironment {
    static let preview = Self(
        webService: .preview,
        mainQueue: .immediate,
        persistence: .preview
    )
}
#endif
