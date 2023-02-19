import Foundation
import ComposableArchitecture
import ComposableArchitectureUtils

public struct PremiumClubFeature: Reducer {
    public enum Source {
        case pin
        case appIcon
    }

    public struct State: Equatable {
        public var source: Source?
        public var hasPremium: Bool

        #if DEBUG
        var debugRow = DebugPremiumClubRow.State()
        #endif

        public init(
            source: Source? = nil,
            hasPremium: Bool? = nil
        ) {
            self.source = source
            @Dependency(\.premiumService) var premiumService
            self.hasPremium = hasPremium ?? premiumService.isCurrentlyPremium
        }
    }

    public enum Action: Equatable {
        case task
        case _setIsPremium(Bool)
        #if DEBUG
        case debugRow(DebugPremiumClubRow.Action)
        #endif
    }

    @Dependency(\.premiumService) var premiumService

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return listenToPremiumUpdates()
            case let ._setIsPremium(value):
                state.hasPremium = value
                return .none
            default:
                return .none
            }
        }

        #if DEBUG
        Scope(state: \.debugRow, action: /Action.debugRow) {
            DebugPremiumClubRow()
        }
        #endif
    }

    private func listenToPremiumUpdates() -> Effect<Action> {
        return .run { send in
            for await value in premiumService.isPremium.removeDuplicates().values {
                await send(._setIsPremium(value))
            }
        }
    }
}
