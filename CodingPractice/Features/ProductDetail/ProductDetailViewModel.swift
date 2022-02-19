import Foundation

final class ProductDetailViewModel {
    private let repository: ProductDetailRepoitoryInterface
    
    private let productId: String
    private var callback: (ProductDetailState) -> Void = { _ in }
    
    init(productId: String, repository: ProductDetailRepoitoryInterface) {
        self.productId = productId
        self.repository = repository
    }
    
    func onProductDetailChange(_ callback: @escaping (ProductDetailState) -> Void) {
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
