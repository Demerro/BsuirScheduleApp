import SwiftUI
import BsuirApi
import ComposableArchitecture

public struct ReachabilityView: View {
    let store: StoreOf<ReachabilityFeature>

    public init(store: StoreOf<ReachabilityFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(
            store,
            observe: { (host: $0.host, status: $0.status) },
            removeDuplicates: ==
        ) { viewStore in
            Label {
                Text(viewStore.host)
            } icon: {
                switch viewStore.status {
                case .unknown:
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(.yellow)
                case .notReachable:
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(.red)
                case .reachable:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .task { await viewStore.send(.task).finish() }
        }
    }
}
