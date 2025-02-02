import SwiftUI
import AppFeature
import BsuirCore
import BsuirApi
import BsuirUI
import ComposableArchitecture

@main
struct App: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            #if DEBUG
            DebugAppView(appDelegate: appDelegate)
            #else
            AppView(store: appDelegate.store)
            #endif
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    private(set) lazy var store = Store(initialState: .init()) {
        AppFeature()
            .dependency(\.imageCache, .default)
            #if DEBUG
            .transformDependency(\.date.now) { [isTestingEnabled] now in
                if isTestingEnabled { now = Date(timeIntervalSince1970: 1699830000) }
            }
            #endif
    }

    override init() {
        super.init()

        #if DEBUG
        if isTestingEnabled { disableAnimations() }
        #endif

        @Dependency(\.productsService) var productsService
        productsService.load()

        @Dependency(\.telemetryService) var telemetryService
        telemetryService.setup()
        telemetryService.sendAppDidFinishLaunching()

        @Dependency(\.cloudSyncService) var cloudSyncService
        cloudSyncService.load()
    }
}

#if DEBUG
private struct DebugAppView: View {
    let appDelegate: AppDelegate

    var body: some View {
        WithPerceptionTracking {
            if appDelegate.isWidgetsPreviewEnabled {
                ScheduleWidgetPreviews()
            } else {
                AppView(store: appDelegate.store)
            }
        }
    }
}

private extension AppDelegate {
    var isTestingEnabled: Bool {
        CommandLine.arguments.contains("enable-testing")
    }

    var isWidgetsPreviewEnabled: Bool {
        CommandLine.arguments.contains("enable-widget-preview")
    }

    func disableAnimations() {
        UIView.setAnimationsEnabled(false)
        UIApplication.shared.keyWindow?.layer.speed = 100
    }
}

private extension UIApplication {
    var keyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
}
#endif
