import PremiumClubFeature
import EntityScheduleFeature
import ScheduleCore
import ComposableArchitecture
import ScheduleFeature

public struct PinnedTabFeature: Reducer {
    public struct State: Equatable {
        var isPremiumLocked: Bool
        var pinnedSchedule: PinnedScheduleFeature.State?
    }

    public enum Action: Equatable {
        public enum Delegate: Equatable {
            case showPremiumClubPinned
        }

        case pinnedSchedule(PinnedScheduleFeature.Action)
        case learnAboutPremiumClubTapped
        case delegate(Delegate)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .learnAboutPremiumClubTapped:
                return .send(.delegate(.showPremiumClubPinned))

            case .pinnedSchedule(.delegate(let action)):
                switch action {
                case .showPremiumClubPinned:
                    return .send(.delegate(.showPremiumClubPinned))
                }

            case .pinnedSchedule, .delegate:
                return .none
            }
        }
        .ifLet(\.pinnedSchedule, action: /Action.pinnedSchedule) {
            PinnedScheduleFeature()
        }
    }
}

// MARK: - Selection

extension PinnedTabFeature.State {
    mutating func switchDisplayType(_ displayType: ScheduleDisplayType) {
        pinnedSchedule?.switchDisplayType(displayType)
    }

    mutating func show(pinned: ScheduleSource) {
        pinnedSchedule = .init(pinned: pinned)
    }

    mutating func resetPinned() {
        pinnedSchedule = nil
    }

    mutating func reset() {
        pinnedSchedule?.reset()
    }
}
