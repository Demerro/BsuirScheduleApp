import Foundation
import BsuirApi
import ComposableArchitecture
import ComposableArchitectureUtils

public struct LecturersSearch: Reducer {
    public struct State: Equatable {
        @BindingState var query: String = ""
        fileprivate(set) var dismiss: Bool = false
    }

    public enum Action: Equatable, BindableAction, FeatureAction {
        public enum ViewAction: Equatable {
            case filter
        }

        public typealias ReducerAction = Never

        public enum DelegateAction: Equatable {
            case didUpdateImportantState
        }

        case binding(BindingAction<State>)
        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.$query):
                if state.query.isEmpty {
                    state.dismiss = false
                }
                return .none

            case .view(.filter):
                return .send(.delegate(.didUpdateImportantState))

            case .binding, .delegate:
                return .none
            }
        }
    }
}

// MARK: - Matching

extension LecturersSearch.State {
    func matches(lector: Employee) -> Bool {
        guard !query.isEmpty else { return true }
        return lector.fio.localizedCaseInsensitiveContains(query)
    }
}

// MARK: - Reset

extension LecturersSearch.State {
    @discardableResult
    mutating func reset() -> Bool {
        guard !query.isEmpty else { return false }
        dismiss = true
        return true
    }
}
