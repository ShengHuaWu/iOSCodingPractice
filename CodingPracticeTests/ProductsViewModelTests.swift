import XCTest
@testable import CodingPractice

final class ProductsViewModelTests: XCTestCase {
    private var webService: MockWebService!
    private var subject: ProductsViewModel!
    
    override func setUp() {
        super.setUp()
        
        self.webService = MockWebService()
        self.subject = ProductsViewModel(webService: self.webService)
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
        
        var callbackCallCount = 0
        self.subject.register {
            callbackCallCount += 1
        }
        
        self.subject.getProducts()
        
        XCTAssertEqual(self.webService.getProductsCallCount, 1)
        XCTAssertEqual(callbackCallCount, 1)
        XCTAssertEqual(self.subject.getNumberOfProducts(), 1)
    }
    
    func testGetProductsFails() {        
        self.webService.expectedError = WebServiceError(context: "Get products", reason: "failure")
        
        var callbackCallCount = 0
        self.subject.register {
            callbackCallCount += 1
        }
        
        self.subject.getProducts()
        
        XCTAssertEqual(self.webService.getProductsCallCount, 1)
        XCTAssertEqual(callbackCallCount, 1)
        XCTAssertEqual(self.subject.getNumberOfProducts(), 0)
    }
}
