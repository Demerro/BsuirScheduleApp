import SwiftUI
import ComposableArchitecture
import ComposableArchitectureUtils

struct ContiniousScheduleView: View {
    let store: StoreOf<ContiniousScheduleFeature>
    let pairDetails: ScheduleGridViewPairDetails

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                if viewStore.days.isEmpty {
                    ScheduleEmptyView()
                } else {
                    ScheduleGridView(
                        days: viewStore.days,
                        loadMore: { viewStore.send(.loadMoreIndicatorAppear) },
                        pairDetails: pairDetails,
                        isOnTop: viewStore.binding(\.$isOnTop)
                    )
                }
            }
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}
