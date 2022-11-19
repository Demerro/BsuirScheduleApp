import Foundation
import GroupsFeature
import LecturersFeature
import AboutFeature
import Deeplinking
import ComposableArchitecture
import ComposableArchitectureUtils

struct AppFeature: ReducerProtocol {
    struct State: Equatable {
        var selection: CurrentSelection
        var overlay: CurrentOverlay?

        var groups = GroupsFeature.State()
        var lecturers = LecturersFeature.State()
        var about = AboutFeature.State()
    }

    enum Action {
        case handleDeeplink(URL)
        case setSelection(CurrentSelection)
        case setOverlay(CurrentOverlay?)
        case showAboutButtonTapped

        case groups(GroupsFeature.Action)
        case lecturers(LecturersFeature.Action)
        case about(AboutFeature.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .setSelection(value):
                updateSelection(state: &state, value)
                state.selection = value
                return .none

            case let .setOverlay(value):
                state.overlay = value
                return .none

            case .showAboutButtonTapped:
                state.overlay = .about
                return .none

            case let .handleDeeplink(url):
                do {
                    let deeplink = try deeplinkRouter.match(url: url)
                    handleDeepling(state: &state, deeplink: deeplink)
                } catch {
                    assertionFailure("Failed to parse deeplink. \(error.localizedDescription)")
                }
                return .none

            case .groups, .lecturers, .about:
                return .none
            }
        }

        Scope(state: \.groups, action: /Action.groups) {
            GroupsFeature()
        }

        Scope(state: \.lecturers, action: /Action.lecturers) {
            LecturersFeature()
        }

        Scope(state: \.about, action: /Action.about) {
            AboutFeature()
        }
    }

    private func handleDeepling(state: inout State, deeplink: Deeplink) {
        switch deeplink {
        case .groups:
            state.selection = .groups
            state.groups.reset()
        case let .group(name):
            state.selection = .groups
            state.groups.openGroup(named: name)
        case .lecturers:
            state.selection = .lecturers
            state.lecturers.reset()
        case let .lector(id):
            state.selection = .lecturers
            state.lecturers.openLector(id: id)
        }
    }

    private func updateSelection(state: inout State, _ newValue: CurrentSelection) {
        guard newValue == state.selection else {
            state.selection = newValue
            return
        }

        // Handle tap on already selected tab
        switch newValue {
        case .groups:
            state.groups.reset()
        case .lecturers:
            state.lecturers.reset()
        case .about:
            state.about.reset()
        }
    }
}
