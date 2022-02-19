import XCTest
@testable import CodingPractice

final class ProductFeatureRepositoryTests: XCTestCase {
    private var webService: MockWebService!
    private var subject: ProductFeatureRepository!
    
    override func setUp() {
        super.setUp()
        
        self.webService = MockWebService()
        self.subject = ProductFeatureRepository(webService: self.webService)
    }
    
    func testGetProductsSucceeds() {
        self.webService.expectedProducts = [
            Product(
                id: "ABC",
                title: "This is a product",
                description: "nothing to mention here",
                volume: nil
            )
        ]
        
        var states: [ProductsRepositoryState] = []
        self.subject.onProductsChange { state in
            states.append(state)
        }
        
        self.subject.getProducts()
        
        XCTAssertEqual(self.webService.getProductsCallCount, 1)
        XCTAssertEqual(states, [.updateAll])
        XCTAssertEqual(self.subject.getNumberOfProducts(), 1)
    }
    
    func testGetProductsFails() {
        self.webService.expectedError = WebServiceError(context: "Get products", reason: "failure")
        
        var states: [ProductsRepositoryState] = []
        self.subject.onProductsChange { state in
            states.append(state)
        }
        
        self.subject.getProducts()
        
        XCTAssertEqual(self.webService.getProductsCallCount, 1)
        XCTAssertEqual(states, [.error])
        XCTAssertEqual(self.subject.getNumberOfProducts(), 0)
    }
    
    func testToggleIsFavorited() {
        let product = Product(
            id: "ABC",
            title: "This is a product",
            description: "nothing to mention here",
            volume: nil
        )
        self.webService.expectedProducts = [product]
        
        var states: [ProductsRepositoryState] = []
        self.subject.onProductsChange { state in
            states.append(state)
        }
        
        self.subject.getProducts()
        
        self.subject.toggleIsFavorited(with: product.id)
        
        XCTAssertEqual(self.webService.getProductsCallCount, 1)
        XCTAssertEqual(states, [.updateAll, .update(row: 0)])
        XCTAssertEqual(self.subject.getNumberOfProducts(), 1)
        XCTAssertTrue(self.subject.getProduct(at: 0)?.isFavorited ?? false)
    }
}
