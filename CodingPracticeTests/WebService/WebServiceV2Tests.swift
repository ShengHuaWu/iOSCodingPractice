@testable import CodingPractice
import XCTest

final class WebServiceV2Tests: XCTestCase {
    private var webService: WebServiceClientV2!
    
    private var urlSession: MockURLSessionService!
    private var dataProcessor: MockDataProcessorService!
    
    override func setUp() {
        super.setUp()
        
        urlSession = MockURLSessionService()
        dataProcessor = MockDataProcessorService()
        webService = .init(
            urlSession: urlSession,
            dataProcessor: dataProcessor
        )
    }
    
    func test_GetProducts_Success() async throws {
        let data = """
        {
            "data": [
                {
                    "id": "some-id",
                    "title": "some-title",
                    "description": "some-description",
                    "volume": 128
                },
                {
                    "id": "another-id",
                    "title": "another-title",
                    "description": "another-description",
                    "volume": 934
                }
            ]
        }
        """.data(using: .utf8)!
        urlSession.expectedData = data
        
        let response = HTTPURLResponse(
            url: .init(string: "https://apple.com")!,
            statusCode: 200,
            httpVersion: "1.1",
            headerFields: [:]
        )!
        urlSession.expectedResponse = response
        
        let expectedProducts = [
            Product(
                id: "some-id",
                title: "some-title",
                description: "some-description",
                volume: 128
            ),
            .init(
                id: "another-id",
                title: "another-title",
                description: "another-description",
                volume: 934
            )
        ]
        dataProcessor.expectedModel = ProductsContainer(data: expectedProducts)
        
        let products = try await webService.getProducts()
        
        XCTAssertEqual(products, expectedProducts)
    }
}
