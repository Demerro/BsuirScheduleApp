import SwiftUI
import GroupsFeature
import LecturersFeature
import SettingsFeature
import ComposableArchitecture
import SwiftUINavigation

struct RegularRootView: View {
    let store: StoreOf<AppFeature>

    struct ViewState: Equatable {
        var selection: CurrentSelection
        var overlay: CurrentOverlay?

        init(state: AppFeature.State) {
            self.selection = state.selection
            self.overlay = state.overlay
        }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            NavigationView {
                TabView(selection: viewStore.binding(get: \.selection, send: AppFeature.Action.setSelection)) {
                    // Placeholder
                    // When in NavigationView first tab is not visible on iPad
                    Text("Oops").opacity(0)

                    GroupsFeatureView(
                        store: store.scope(
                            state: \.groups,
                            action: AppFeature.Action.groups
                        )
                    )
                    .tag(CurrentSelection.groups)
                    .tabItem { GroupsLabel() }

                    LecturersFeatureView(
                        store: store.scope(
                            state: \.lecturers,
                            action: AppFeature.Action.lecturers
                        )
                    )
                    .tag(CurrentSelection.lecturers)
                    .tabItem { LecturersLabel() }
                }
                .toolbar {
                    Button {
                        viewStore.send(.showSettingsButtonTapped)
                    } label: {
                        SettingsLabel()
                    }
                }

                SchedulePlaceholder()
            }
            .sheet(
                unwrapping: viewStore.binding(get: \.overlay, send: AppFeature.Action.setOverlay),
                case: /CurrentOverlay.settings
            ) { _ in
                NavigationView {
                    SettingsFeatureView(
                        store: store.scope(
                            state: \.settings,
                            action: AppFeature.Action.settings
                        )
                    )
                }
            }
        }
    }
}

private struct SchedulePlaceholder: View {
    var body: some View {
        Text("screen.schedule.placeholder.title")
    }
}
