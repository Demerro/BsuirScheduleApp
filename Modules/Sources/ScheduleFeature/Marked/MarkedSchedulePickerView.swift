import SwiftUI
import ComposableArchitecture

// TODO: Localize!!!

struct MarkedSchedulePickerView: View {
    enum ViewState: Identifiable, Hashable, CaseIterable {
        var id: Self { self }
        case pinned
        case favorite
        case nothing
    }

    enum ViewAction: Equatable {
        case task
        case setSelection(ViewState)
    }

    let store: StoreOf<MarkedScheduleFeature>

    var body: some View {
        WithViewStore(store, observe: ViewState.init, send: MarkedScheduleFeature.Action.init) { viewStore in
            Picker(
                "Schedule mark",
                selection: viewStore.binding(
                    get: { $0 },
                    send: { .setSelection($0) }
                )
            ) {
                ForEach(ViewState.allCases) { $0.label(selected: $0 == viewStore.state) }
            }
            .task { await ViewStore(store.stateless).send(.task).finish() }
            .accentColor(viewStore.tint)
        }
    }
}

private extension MarkedSchedulePickerView.ViewState {
    @ViewBuilder
    func label(selected: Bool) -> some View {
        switch self {
        case .pinned:
            Label("Pin", systemImage: selected ? "pin.fill" : "pin")
        case .favorite:
            Label("Favorite", systemImage: selected ? "star.fill" : "star")
        case .nothing:
            Label("Don't save", systemImage: "square.dashed")
        }
    }

    var tint: Color {
        switch self {
        case .pinned: return .red
        case .favorite: return .yellow
        case .nothing: return .gray
        }
    }
}

private extension MarkedSchedulePickerView.ViewState {
    init(_ state: MarkedScheduleFeature.State) {
        if state.isPinned {
            self = .pinned
        } else if state.isFavorite {
            self = .favorite
        } else {
            self = .nothing
        }
    }
}

private extension MarkedScheduleFeature.Action {
    init(_ action: MarkedSchedulePickerView.ViewAction) {
        switch action {
        case .task:
            self = .view(.task)
        case .setSelection(.pinned):
            self = .view(.moveToPinButtonTapped)
        case .setSelection(.favorite):
            self = .view(.moveToFavoriteButtonTapped)
        case .setSelection(.nothing):
            self = .view(.unsaveButtonTapped)
        }
    }
}