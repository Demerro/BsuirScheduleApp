//
//  AppState.swift
//  BsuirScheduleApp
//
//  Created by Anton Siliuk on 9/28/19.
//  Copyright © 2019 Saute. All rights reserved.
//

import Foundation
import BsuirApi
import Combine
import UIKit
import Kingfisher
import BsuirUI

import os.log

extension OSLog {

    static let appState = bsuirSchedule(category: "AppState")

    static func bsuirSchedule(category: String) -> OSLog {
        OSLog(subsystem: "com.asiliuk.BsuirScheduleApp", category: category)
    }
}

final class AppState: ObservableObject {
    @Published var currentSelection: CurrentSelection?

    init() {
        self.requestManager = .iisBsuir()
        self.currentSelection = favorites.isEmpty ? .groups : .favorites
        deeplinkHandler.deeplink()
            .map { deeplink in
                switch deeplink {
                case .groups:
                    return .groups
                case .lecturers:
                    return .lecturers
                }
            }
            .assign(to: &$currentSelection)
    }

    private let storage: UserDefaults = .standard
    private let sharedStorage: UserDefaults = .asiliukShared
    private let requestManager: RequestsManager
    private lazy var favorites = FavoritesContainer(storage: storage)
    private(set) lazy var deeplinkHandler = DeeplinkHandler()
    private(set) lazy var reviewRequestService = ReviewRequestService(storage: storage)
    private(set) lazy var pairFormColorService = PairFormColorService(storage: sharedStorage)

    // MARK: - Screens

    private(set) lazy var allFavorites = AllFavoritesScreen(
        requestManager: requestManager,
        favorites: favorites
    )

    private(set) lazy var allGroups = AllGroupsScreen(
        requestManager: requestManager,
        favorites: favorites,
        deeplinkHandler: deeplinkHandler
    )

    private(set) lazy var allLecturers = AllLecturersScreen(
        requestManager: requestManager,
        favorites: favorites,
        deeplinkHandler: deeplinkHandler
    )

    private(set) lazy var about = AboutScreen(
        urlCache: requestManager.cache,
        imageCache: .default
    )
}
