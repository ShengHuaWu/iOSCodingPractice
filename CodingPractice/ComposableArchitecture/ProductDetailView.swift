import ComposableArchitecture
import SwiftUI

struct ProductDetailView: View {
    let store: Store<AppState, AppAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                VStack {
                    Text(viewStore.state.productDetail?.description ?? "Product Description")
                        .font(.title2)
                    Spacer()
                    Button(
                        action: {
                            viewStore.send(.toggleProductIsFavorite(viewStore.state.productDetail!.id))
                        },
                        label: {
                            if viewStore.state.productDetail?.isFavorited == true {
                                Text("Unfavorite")
                                    .foregroundColor(.gray)
                            } else {
                                Text("Favorite")
                                    .foregroundColor(.red)
                            }
                        }
                    ).font(.title3)
                    Spacer()
                }
                
            }
            .navigationTitle(viewStore.state.productDetail?.title ?? "Product Name")
        }
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(store: .init(
            initialState: .init(),
            reducer: appReducer,
            environment: .preview
        ))
    }
}
