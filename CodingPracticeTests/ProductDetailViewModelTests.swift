import XCTest
@testable import CodingPractice

final class ProductDetailViewModelTests: XCTestCase {
    private var repository: MockProductDetailRepository!
    private var subject: ProductDetailViewModel!
    
    private var productId = "999"
    
    override func setUp() {
        super.setUp()
        
        self.repository = MockProductDetailRepository()
        self.subject = ProductDetailViewModel(
            productId: self.productId,
            repository: self.repository
        )
    }
    
    func testGetProductDetail() {
        let product = Product(
            id: self.productId,
            title: "title",
            description: "description",
            volume: nil
        )
        
        self.repository.expectedProduct = product
        
        var states: [ProductDetailState] = []
        self.subject.onProductDetailChange { state in
            states.append(state)
        }
        
        self.subject.getProductDetail()
        
        XCTAssertEqual(self.repository.getProductCallCount, 1)
        XCTAssertEqual(self.repository.receivedProductId, self.productId)
        
        let expectedDisplayInfo = ProductDetailDisplayInfo(
            title: product.title,
            description: product.description,
            isFavorited: false
        )
        XCTAssertEqual(states, [.present(expectedDisplayInfo)])
    }
}
