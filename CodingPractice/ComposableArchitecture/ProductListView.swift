import ComposableArchitecture
import SwiftUI

struct ProductListView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                List {
                    ForEach(viewStore.productRows) { row in
                        NavigationLink(
                            tag: viewStore.state.productDetail,
                            selection: viewStore.binding(
                                get: {  $0.productDetail },
                                send: { _ in AppAction.tapProductRow(row.id) }
                            ),
                            destination: {
                                if viewStore.state.productDetail != nil {
                                    ProductDetailView()
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
                    viewStore.send(.fetchProducts)
                }
            }
        }
    }
}

struct ProductListView_Previews: PreviewProvider {
    static var previews: some View {
        ProductListView(store: .init(
            initialState: .init(),
            reducer: appReducer,
            environment: .preview
        ))
    }
}
