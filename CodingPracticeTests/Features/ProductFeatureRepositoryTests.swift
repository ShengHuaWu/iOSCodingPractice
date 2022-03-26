import XCTest
@testable import CodingPractice

final class ProductFeatureRepositoryTests: XCTestCase {
    private var webService: MockWebService!
    private var persistence: MockPersistence!
    private var subject: ProductFeatureRepository!
    
    override func setUp() {
        super.setUp()
        
        self.webService = MockWebService()
        self.persistence = MockPersistence()
        self.subject = ProductFeatureRepository(
            webService: self.webService,
            persistence: self.persistence
        )
    }
    
    func testGetProductsSucceeds() {
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
        
        XCTAssertEqual(self.webService.getProductsCallCount, 1)
        XCTAssertEqual(states, [.updateAll([product])])
        XCTAssertEqual(self.persistence.storeCallCount, 1)
        XCTAssertEqual(self.persistence.receivedProducts, [product])
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
        XCTAssertEqual(self.persistence.storeCallCount, 0)
        XCTAssertTrue(self.persistence.receivedProducts.isEmpty)
    }
    
    func testGetProductWithId() {
        let product = Product(
            id: "ABC",
            title: "This is a product",
            description: "nothing to mention here",
            volume: nil
        )
        self.persistence.expectedProduct = product
        
        let result = self.subject.getProduct(with: product.id)
        
        XCTAssertEqual(self.persistence.getProductWithIdCallCount, 1)
        XCTAssertEqual(self.persistence.receivedProductId, product.id)
        XCTAssertEqual(result, product)
    }
    
    func testToggleIsFavorited() {
        let productId = "ABC"
        let isFavorited = true
        
        self.persistence.expectedIsFavorited = isFavorited
        
        var states: [ProductsRepositoryState] = []
        self.subject.onProductsChange { state in
            states.append(state)
        }
                
        self.subject.toggleIsFavorited(with: productId)
        
        XCTAssertEqual(self.persistence.toggleIsFavoritedCallCount, 1)
        XCTAssertEqual(self.persistence.receivedProductId, productId)
        XCTAssertEqual(states, [.update(id: productId, isFavorited: isFavorited)])
    }
}
