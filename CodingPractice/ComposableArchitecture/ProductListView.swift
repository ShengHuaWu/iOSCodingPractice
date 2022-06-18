import ComposableArchitecture
import SwiftUI

struct ProductListState: Equatable {
    var rows: [ProductRowDisplayInfo] = []
    var selectedProductId: String?
    var errorMessage: String = ""
}

enum ProductListAction: Equatable {
    case loadList
    case listLoaded(Result<[Product], AppError>)
    case presentDetail(String)
}

let productListReducer = Reducer<ProductListState, ProductListAction, AppEnvironment> { state, action, environment in
    switch action {
    case .loadList:
        state.selectedProductId = nil
        
        guard state.rows.isEmpty else {
            return .none
        }
        
        return environment
            .webService
            .getProducts()
            .mapError(AppError.init(webServiceError:))
            .flatMap(environment.persistence.storeProducts)
            .receive(on: environment.mainQueue)
            .catchToEffect(ProductListAction.listLoaded)
        
    case let .listLoaded(.success(products)):
        state.rows = products.map(ProductRowDisplayInfo.init(product:))
                
        return .none
        
    case let .listLoaded(.failure(error)):
        state.errorMessage = error.description
        
        return .none
        
    case let .presentDetail(productId):
        state.selectedProductId = productId
        
        return .none
    }
}

struct ProductListView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                List {
                    ForEach(viewStore.state.productList.rows) { row in
                        NavigationLink(
                            tag: row.id,
                            selection: viewStore.binding(
                                get: {  $0.productDetail?.detail?.id },
                                send: { _ in AppAction.loadProduct(row.id) }
                            ),
                            destination: {
                                if viewStore.state.productDetail != nil {
                                    ProductDetailView(store: self.store)
                                } else {
                                    Text("No product detail")
                                }
                            },
                            label: {
                                VStack(alignment: .leading) {
                                    Text(row.title).font(.title)
                                    if row.isFavorited {
                                        Text("favorited").foregroundColor(.red)
                                    } else {
                                        Text("not favorited")
                                    }
                                }
                            }
                        )
                    }
                }
                .navigationTitle("Product List")
                .onAppear {
                    viewStore.send(.loadProductList)
                }
            }
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView(store: .init(
            initialState: .init(
                productList: .init()
            ),
            reducer: appReducer,
            environment: .preview
        ))
    }
}
