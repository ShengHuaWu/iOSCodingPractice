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
        let product = Product(
            id: "ABC",
            title: "This is a product",
            description: "nothing to mention here",
            volume: nil
        )
        self.repository.expectedProducts = [product]
        
        var states = [ProductsEvent]()
        self.subject.subscribe { state in
            states.append(state)
        }
        
        self.subject.getProducts()
        
        XCTAssertEqual(self.repository.onProductsChangeCallCount, 1)
        XCTAssertEqual(self.repository.getProductsCallCount, 1)
        XCTAssertEqual(states, [.loading, .loaded([.init(product: product)])])
    }
    
    func testGetProductsFails() {
        struct PlaceholderError: Error {}
        
        self.repository.expectedError = PlaceholderError()
        
        var states = [ProductsEvent]()
        self.subject.subscribe { state in
            states.append(state)
        }
        
        self.subject.getProducts()
        
        XCTAssertEqual(self.repository.onProductsChangeCallCount, 1)
        XCTAssertEqual(self.repository.getProductsCallCount, 1)
        XCTAssertEqual(states, [.loading, .error])
    }
    
    func testPresentProductDetail() {
        let product = Product(
            id: "ABC",
            title: "This is a product",
            description: "nothing to mention here",
            volume: nil
        )
        self.repository.expectedProducts = [product]
        
        var states = [ProductsEvent]()
        self.subject.subscribe { state in
            states.append(state)
        }
        
        self.subject.getProducts()
        
        XCTAssertEqual(self.repository.onProductsChangeCallCount, 1)
        XCTAssertEqual(self.repository.getProductsCallCount, 1)
        XCTAssertEqual(states, [.loading, .loaded([.init(product: product)])])
    }
}
