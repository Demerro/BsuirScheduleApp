//
//  RootView.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import SwiftUI
import AboutFeature

enum CurrentSelection: Hashable {
    case legacyGroups
    case groups
    case legacyLecturers
    case lecturers
    case favorites
    case about
}

enum CurrentOverlay: Identifiable {
    var id: Self { self }
    case about
}

struct RootView: View {
    @ObservedObject var state: AppState
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var currentOverlay: CurrentOverlay?

    var body: some View {
        content
            .onOpenURL(perform: state.deeplinkHandler.handle(url:))
            .sheet(item: $currentOverlay) { overlay in
                switch overlay {
                case .about:
                    NavigationView { AboutView(store: state.aboutStore) }
                }
            }
    }

    @ViewBuilder private var content: some View {
        switch horizontalSizeClass {
        case nil, .compact?:
            CompactRootView(state: state, currentSelection: $state.currentSelection)
        case .regular?:
            RegularRootView(state: state, currentSelection: $state.currentSelection, currentOverlay: $currentOverlay)
        case .some:
            EmptyView().onAppear { assertionFailure("Unexpected horizontalSizeClass") }
        }
    }
}

extension CurrentSelection {
    @ViewBuilder var label: some View {
        switch self {
        case .legacyGroups:
            Label("view.tabBar.groups.title", systemImage: "person.2")
        case .groups:
            Label("view.tabBar.groups.title", systemImage: "person.2.badge.gearshape")
        case .legacyLecturers:
            Label("view.tabBar.lecturers.title", systemImage: "person.text.rectangle")
        case .lecturers:
            Label("view.tabBar.lecturers.title", systemImage: "person.crop.square.filled.and.at.rectangle")
        case .about:
            Label("view.tabBar.about.title", systemImage: "info.circle")
        case .favorites:
            Label("view.tabBar.favorites.title", systemImage: "star")
        }
    }
}
