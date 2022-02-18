import XCTest
@testable import CodingPractice

final class ProductsViewModelTests: XCTestCase {
    private var repository: MockProductsRepository!
    private var routing: MockRouting!
    private var subject: ProductsViewModel!
    
    override func setUp() {
        super.setUp()
        
        self.repository = MockProductsRepository()
        self.routing = MockRouting()
        self.subject = ProductsViewModel(
            repository: self.repository,
            routing: self.routing
        )
    }
    
    func testGetProductsSucceeds() {
        self.repository.expectedProducts = [
            Product(
                id: "ABC",
                title: "This is a product",
                description: "nothing to mention here",
                volume: nil
            )
        ]
        
        var states = [ProductsState]()
        self.subject.onStateChange { state in
            states.append(state)
        }
        
        self.subject.getProducts()
        
        XCTAssertEqual(self.repository.onProductsChangeCallCount, 1)
        XCTAssertEqual(self.repository.getProductsCallCount, 1)
        XCTAssertEqual(states, [.loading, .loaded])
        XCTAssertEqual(self.subject.getNumberOfProducts(), 1)
    }
    
    func testGetProductsFails() {
        struct PlaceholderError: Error {}
        
        self.repository.expectedError = PlaceholderError()
        
        var states = [ProductsState]()
        self.subject.onStateChange { state in
            states.append(state)
        }
        
        self.subject.getProducts()
        
        XCTAssertEqual(self.repository.onProductsChangeCallCount, 1)
        XCTAssertEqual(self.repository.getProductsCallCount, 1)
        XCTAssertEqual(states, [.loading, .error])
        XCTAssertEqual(self.subject.getNumberOfProducts(), 0)
    }
    
    func testGetProductRow() {
        let product = Product(
            id: "ABC",
            title: "This is a product",
            description: "nothing to mention here",
            volume: nil
        )
        
        self.repository.expectedProducts = [product]
        
        let displayInfo = subject.getProductRow(at: 0)
        
        XCTAssertEqual(self.repository.getProductCallCount, 1)
        XCTAssertEqual(displayInfo.title, product.title)
        XCTAssertFalse(displayInfo.isFavorited)
    }
    
    func testPresentProductDetail() {
        self.repository.expectedProducts = [
            Product(
                id: "ABC",
                title: "This is a product",
                description: "nothing to mention here",
                volume: nil
            )
        ]
        
        subject.presentProductDetail(at: 0)
        
        XCTAssertEqual(self.repository.getProductIdCallCount, 1)
        XCTAssertEqual(self.routing.presentProductDetailCallCount, 1)
        XCTAssertEqual(self.routing.receivedProductId, "ABC")
    }
}
