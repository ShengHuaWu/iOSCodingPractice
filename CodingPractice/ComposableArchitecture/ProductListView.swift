import ComposableArchitecture
import SwiftUI

struct ProductListState: Equatable {
    var rows: [ProductRowDisplayInfo] = []
    var selection: Identified<String, ProductDetailState?>?
    var errorMessage: String = ""
}

enum ProductListAction: Equatable {
    case loadList
    case listLoaded(Result<[Product], AppError>)
    case setNavigation(String?)
    case detail(ProductDetailAction)
}

let productListReducer = productDetailReducer
    .optional()
    .pullback(
        state: \Identified.value,
        action: .self,
        environment: { $0 }
    )
    .optional()
    .pullback(
        state: \ProductListState.selection,
        action: /ProductListAction.detail,
        environment: { $0 }
    )
    .combined(with: Reducer<ProductListState, ProductListAction, AppEnvironment> { state, action, environment in
        switch action {
        case .loadList:            
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
            
        case let .setNavigation(.some(id)):
            state.selection = Identified(.init(productId: id), id: id)
            
            return .none
            
        case .setNavigation(.none):
            state.selection = nil
            
            return .none
            
        case let .detail(.detailLoaded(product)):
            if let index = state.rows.firstIndex(where: { $0.id == product.id }) {
                state.rows.remove(at: index)
                state.rows.insert(.init(product: product), at: index)
            }
            
            return .none
            
        case .detail:
            return .none
        }
    })

struct ProductListView: View {
    let store: Store<ProductListState, ProductListAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                List {
                    ForEach(viewStore.state.rows) { row in
                        NavigationLink(
                            tag: row.id,
                            selection: viewStore.binding(
                                get: \.selection?.id,
                                send: ProductListAction.setNavigation
                            ),
                            destination: {
                                IfLetStore(
                                    self.store.scope(
                                        state: \.selection?.value,
                                        action: ProductListAction.detail
                                    ),
                                    then: ProductDetailView.init(store:),
                                    else: {
                                        Text("No product detail")
                                    }
                                )
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
                    viewStore.send(.loadList)
                }
            }
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView(store: .init(
            initialState: .init(),
            reducer: productListReducer,
            environment: .preview
        ))
    }
}
