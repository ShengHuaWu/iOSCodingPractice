import Foundation

final class ProductDetailViewModel {
    private let repository: ProductDetailRepoitory
    
    private let productId: String
    private var callback: (ProductDetailEvent) -> Void = { _ in }
    
    init(productId: String, repository: ProductDetailRepoitory) {
        self.productId = productId
        self.repository = repository
    }
    
    func subscribe(_ callback: @escaping (ProductDetailEvent) -> Void) {
        self.callback = callback
    }
    
    func getProductDetail() {
        guard let product = self.repository.getProduct(with: self.productId) else {
            self.callback(.error)
            return
        }
        
        let displayInfo = ProductDetailDisplayInfo(
            title: product.title,
            description: product.description,
            isFavorited: product.isFavorited
        )
        self.callback(.present(displayInfo))
    }
    
    func toggleIsFavorited() {
        self.repository.toggleIsFavorited(with: self.productId)
        self.getProductDetail()
    }
}
