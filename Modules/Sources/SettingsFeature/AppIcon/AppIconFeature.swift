import Foundation
import UIKit
import BsuirCore
import BsuirUI
import ComposableArchitecture

public struct AppIconFeature: Reducer {
    public struct State: Equatable {
        // TODO: new navigation logic
        var alert: AlertState<Action>?

        var supportsIconPicking: Bool = {
            @Dependency(\.application.supportsAlternateIcons) var supportsAlternateIcons
            return supportsAlternateIcons()
        }()

        var currentIcon: AppIcon? = {
            @Dependency(\.application.alternateIconName) var alternateIconName
            return alternateIconName().flatMap(AppIcon.init(name:)) ?? .plain(.standard)
        }()

        var isPremiumLocked: Bool = false
    }
    
    public enum Action: Equatable {
        public enum DelegateAction: Equatable {
            case showPremiumClub
        }

        case task
        case alertDismissed
        case learnAboutPremiumClubButtonTapped
        case iconPicked(AppIcon?)
        
        case _iconChanged(AppIcon?)
        case _iconChangeFailed
        case _setIsPremiumLocked(Bool)

        case delegate(DelegateAction)
    }

    @Dependency(\.application.setAlternateIconName) var setAlternateIconName
    @Dependency(\.reviewRequestService) var reviewRequestService
    @Dependency(\.premiumService) var premiumService

    public func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .task:
            state.isPremiumLocked = !premiumService.isCurrentlyPremium
            return .run { send in
                for await value in premiumService.isPremium.removeDuplicates().values {
                    await send(._setIsPremiumLocked(!value))
                }
            }
        case .alertDismissed:
            state.alert = nil
            return .none

        case .learnAboutPremiumClubButtonTapped:
            return .send(.delegate(.showPremiumClub))
            
        case let .iconPicked(icon):
            guard icon != state.currentIcon else {
                return .none
            }

            if let icon, state.isPremiumLocked, icon.isPremium {
                state.alert = .premiumLocked
                return .none
            }

            return .task {
                try await setAlternateIconName(icon?.iconName)
                await reviewRequestService.madeMeaningfulEvent(.appIconChanged)
                return ._iconChanged(icon)
            } catch: { _ in
                ._iconChangeFailed
            }
            
        case let ._iconChanged(newIcon):
            state.currentIcon = newIcon
            if let newIcon, newIcon.showNiceChoiceAlert {
                state.alert = .goodIconChoice
            }
            return .none
            
        case ._iconChangeFailed:
            state.alert = .iconUpdateFailed
            return .none

        case ._setIsPremiumLocked(let value):
            state.isPremiumLocked = value
            return .none

        case .delegate:
            return .none
        }
    }
}

// MARK: - AlertState

private extension AlertState where Action == AppIconFeature.Action {
    static let premiumLocked = AlertState(
        title: TextState("Premium Club only"),
        message: TextState("Icon that you're trying to set is available only for **Premium Club** members"),
        buttons: [
            .default(
                TextState("Join Premium Club..."),
                action: .send(.learnAboutPremiumClubButtonTapped)),
            .cancel(TextState("Cancel"))
        ]
    )

    static let goodIconChoice = AlertState(
        title: TextState("alert.goodIconChoice.title"),
        message: TextState("alert.goodIconChoice.message")
    )

    static let iconUpdateFailed = AlertState(
        title: TextState("alert.iconUpdateFailed.title"),
        message: TextState("alert.iconUpdateFailed.message")
    )
}

// MARK: - AppIcon

private extension AppIcon {
    var showNiceChoiceAlert: Bool {
        switch self {
        case .symbol(.resist), .symbol(.national):
            return true
        default:
            return false
        }
    }
}

// MARK: - Event

private extension MeaningfulEvent {
    static let appIconChanged = Self(score: 5)
}
