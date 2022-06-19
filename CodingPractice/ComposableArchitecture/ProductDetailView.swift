import ComposableArchitecture
import SwiftUI

struct ProductDetailState: Equatable {
    var productId: String
    var detail: ProductDetailDisplayInfo?
}

enum ProductDetailAction: Equatable {
    case loadDetail(String)
    case detailLoaded(Product)
    case toggleProductIsFavorite(String)
}

let productDetailReducer = Reducer<ProductDetailState, ProductDetailAction, AppEnvironment> { state, action, environment in
    switch action {
    case let .loadDetail(productId):
        return environment
            .persistence
            .getProduct(productId)
            .receive(on: environment.mainQueue)
            .flatMap(sendDetailLoadedActionIfNeeded)
            .eraseToEffect()
        
    case let .detailLoaded(product):
        state.detail = ProductDetailDisplayInfo(product: product)
        
        return .none
        
    case let .toggleProductIsFavorite(productId):
        return environment
            .persistence
            .toggleProductIsFavorited(productId)
            .receive(on: environment.mainQueue)
            .flatMap(sendDetailLoadedActionIfNeeded)
            .eraseToEffect()
    }
}

private func sendDetailLoadedActionIfNeeded(_ product: Product?) -> Effect<ProductDetailAction, Never> {
    guard let product = product else {
        return .none
    }
    
    return Effect(value: .detailLoaded(product))
}

struct ProductDetailView: View {
    let store: Store<ProductDetailState, ProductDetailAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                VStack {
                    Text(viewStore.state.detail?.description ?? "Product Description")
                        .font(.title2)
                    Spacer()
                    Button(
                        action: {
                            viewStore.send(.toggleProductIsFavorite(viewStore.state.productId))
                        },
                        label: {
                            if viewStore.state.detail?.isFavorited == true {
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
            .navigationTitle(viewStore.state.detail?.title ?? "Product Name")
            .onAppear {
                viewStore.send(.loadDetail(viewStore.state.productId))
            }
        }
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(store: .init(
            initialState: .init(productId: ""),
            reducer: productDetailReducer,
            environment: .preview
        ))
    }
}
