import Foundation
import ComposableArchitecture
import ComposableArchitectureUtils

public struct FakeAdsFeature: Reducer {
    public struct State: Equatable {
        static let config = FakeAdConfig.all.randomElement()!

        var image: FakeAdConfig.AdImage { Self.config.image }
        var label: TextState { TextState(Self.config.label) }
        var title: TextState { TextState(Self.config.title) }
        var description: TextState { TextState(Self.config.description) }

        public init() {}
    }

    public enum Action: Equatable, FeatureAction {
        public enum ViewAction: Equatable {
            case bannerTapped
        }

        public enum ReducerAction: Equatable {}

        public enum DelegateAction: Equatable {
            case showPremiumClub
        }

        case view(ViewAction)
        case reducer(ReducerAction)
        case delegate(DelegateAction)
    }

    public init() {}

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .view(.bannerTapped):
            return .send(.delegate(.showPremiumClub))
        case .reducer, .delegate:
            return .none
        }
    }
}