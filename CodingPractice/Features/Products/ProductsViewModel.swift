import Foundation

final class ProductsViewModel {
    private let repository: ProductsRepository
    private weak var routing: Routing?
    
    private var productRows: [ProductRowDisplayInfo] = []
    private var callback: (ProductsState) -> Void = { _ in }
    
    init(repository: ProductsRepository, routing: Routing) {
        self.repository = repository
        self.routing = routing
    }
    
    func onStateChange(_ callback: @escaping (ProductsState) -> Void) {
        self.repository.onProductsChange { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case let .updateAll(products):
                strongSelf.productRows = products.map(ProductRowDisplayInfo.init(product:))
                callback(.loaded)
                
            case let .update(id):
                strongSelf.productRows.firstIndex(where: { $0.id == id }).map { index in
                    let row = strongSelf.productRows.remove(at: index)
                    let newRow = ProductRowDisplayInfo(
                        id: row.id,
                        title: row.title,
                        isFavorited: !row.isFavorited
                    )
                    strongSelf.productRows.insert(newRow, at: index)
                    callback(.update(row: index))
                }
                
            case .error:
                callback(.error)
            }
        }
        
        self.callback = callback
    }
    
    func getProducts() {
        self.callback(.loading)
        self.repository.getProducts()
    }
    
    func getNumberOfProducts() -> Int {
        return self.productRows.count
    }
    
    func getProductRow(at index: Int) -> ProductRowDisplayInfo {
        guard index < self.productRows.count else {
            assertionFailure("Attempt to show out-of-bound product row")
            
            return .init(
                id: "",
                title: "placeholder title",
                isFavorited: false
            )
        }
        
        return self.productRows[index]
    }
    
    func presentProductDetail(at index: Int) {
        guard index < self.productRows.count else {
            assertionFailure("Attempt to show out-of-bound product detail")
            return
        }
        
        routing?.presentProductDetail(with: self.productRows[index].id)
    }
}
