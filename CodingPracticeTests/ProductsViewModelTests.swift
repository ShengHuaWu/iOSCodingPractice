import XCTest
@testable import CodingPractice

final class ProductsViewModelTests: XCTestCase {
    private var webService: MockWebService!
    private var routing: MockRouting!
    private var subject: ProductsViewModel!
    
    override func setUp() {
        super.setUp()
        
        self.webService = MockWebService()
        self.routing = MockRouting()
        self.subject = ProductsViewModel(
            webService: self.webService,
            routing: self.routing
        )
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
        
        var states = [ProductsState]()
        self.subject.onStateChange { state in
            states.append(state)
        }
        
        self.subject.getProducts()
        
        XCTAssertEqual(self.webService.getProductsCallCount, 1)
        XCTAssertEqual(states, [.loading, .loaded])
        XCTAssertEqual(self.subject.getNumberOfProducts(), 1)
    }
    
    func testGetProductsFails() {        
        self.webService.expectedError = WebServiceError(context: "Get products", reason: "failure")
        
        var states = [ProductsState]()
        self.subject.onStateChange { state in
            states.append(state)
        }
        
        self.subject.getProducts()
        
        XCTAssertEqual(self.webService.getProductsCallCount, 1)
        XCTAssertEqual(states, [.loading, .error])
        XCTAssertEqual(self.subject.getNumberOfProducts(), 0)
    }
    
    func testPresentProductDetail() {
        subject.presentProductDetail(at: 0)
        
        XCTAssertEqual(self.routing.presentProductDetailCallCount, 1)
    }
}
