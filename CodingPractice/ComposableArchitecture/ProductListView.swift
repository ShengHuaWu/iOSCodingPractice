import ComposableArchitecture
import SwiftUI

struct ProductListView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                List {
                    ForEach(viewStore.productRows) { row in
                        Text(row.title)
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
            environment: .live
        ))
    }
}
