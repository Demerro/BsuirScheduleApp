import SwiftUI
import BsuirUI
import BsuirApi
import LoadableFeature
import EntityScheduleFeature
import ComposableArchitecture
import SwiftUINavigation

public struct LecturersFeatureView: View {
    public let store: StoreOf<LecturersFeature>
    
    public init(store: StoreOf<LecturersFeature>) {
        self.store = store
    }

    struct ViewState: Equatable {
        let isOnTop: Bool
        let lectorScheduleId: Int?

        init(_ state: LecturersFeature.State) {
            self.isOnTop = state.isOnTop
            self.lectorScheduleId = state.lectorSchedule?.lector.id
        }
    }
    
    public var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            LoadingLecturersView(
                store: store,
                isOnTop: viewStore.binding(get: \.isOnTop, send: { .view(.setIsOnTop($0)) })
            )
            .navigationDestination(
                unwrapping: viewStore.binding(
                    get: \.lectorScheduleId,
                    send: { .view(.setLectorScheduleId($0)) }
                )
            ) { _ in
                IfLetStore(
                    store
                        .scope(state: \.lectorSchedule, reducerAction: { .lectorSchedule($0) })
                        .returningLastNonNilState()
                ) { store in
                    LectorScheduleView(store: store)
                }
            }
            .navigationTitle("screen.lecturers.navigation.title")
            .task { await viewStore.send(.task).finish() }
        }
    }
}

private struct LoadingLecturersView: View {
    let store: StoreOf<LecturersFeature>
    @Binding var isOnTop: Bool

    var body: some View {
        LoadingStore(
            store,
            state: \.$lecturers,
            loading: \.$loadedLecturers,
            action: { .reducer(.lector(id: $0, action: $1)) }
        ) { store in
            ScrollableToTopList(isOnTop: $isOnTop) {
                IfLetStore(
                    self.store.scope(
                        state: \.pinned,
                        reducerAction: { .pinned($0) }
                    )
                ) { store in
                    Section("screen.lecturers.pinned.section.header") {
                        LecturersRowView(store: store)
                    }
                }

                IfLetStore(self.store.scope(state: \.favorites)) { store in
                    Section("screen.lecturers.favorites.section.header") {
                        ForEachStore(
                            store.scope(
                                state: { $0 },
                                reducerAction: { .favorite(id: $0, action: $1) }
                            )
                        ) { store in
                            LecturersRowView(store: store)
                        }
                    }
                }

                Section {
                    ForEachStore(store.loaded()) { store in
                        LecturersRowView(store: store)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .refreshable { await ViewStore(store.stateless).send(.refresh).finish() }
            .lecturersSearchable(store: self.store.scope(state: \.search, reducerAction: { .search($0) }))
        } loading: {
            LecturersLoadingPlaceholder(store: store)
        } error: { store in
            LoadingErrorView(store: store)
        }
    }
}

private struct LecturersLoadingPlaceholder: View {
    let store: StoreOf<LecturersFeature>

    struct ViewState: Equatable {
        let hasPinned: Bool
        let numberOfFavorites: Int

        init(state: LecturersFeature.State) {
            self.hasPinned = state.pinned != nil
            self.numberOfFavorites = state.favoriteIds.count
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            LecturersPlaceholderView(
                hasPinned: viewStore.hasPinned,
                numberOfFavorites: viewStore.numberOfFavorites
            )
        }
    }
}
