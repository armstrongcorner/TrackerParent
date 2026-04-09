//
//  AppCoordinator.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 24/03/2026.
//

import SwiftUI
import SwiftfulRouting

// MARK: - RouteAction
@MainActor
protocol RouteAction {
    associatedtype Route
    associatedtype Destination: View

    @ViewBuilder
    func destination(for route: Route) -> Destination
}

@MainActor
extension RouteAction {
    func show(_ route: Route, on router: AnyRouter, segue: SegueOption = .push) {
        router.showScreen(segue) { _ in
            destination(for: route)
        }
    }

    func show(_ route: Route, on router: AnyRouter, sheetConfig: ResizableSheetConfig, onDismiss: @escaping () -> Void = {}) {
        router.showScreen(.sheetConfig(config: sheetConfig), onDismiss: {
            onDismiss()
        }) { _ in
            destination(for: route)
        }
    }

    func show<Content: View>(
        on router: AnyRouter,
        sheetConfig: ResizableSheetConfig,
        onDismiss: @escaping () -> Void = {},
        @ViewBuilder destination: @escaping () -> Content
    ) {
        router.showScreen(.sheetConfig(config: sheetConfig), onDismiss: {
            onDismiss()
        }) { _ in
            destination()
        }
    }

    func dismissScreen(on router: AnyRouter) {
        router.dismissScreen()
    }

    func dismissPushStack(on router: AnyRouter) {
        router.dismissPushStack()
    }

    func dismissEnvironment(on router: AnyRouter) {
        router.dismissEnvironment()
    }
}

// MARK: - AppCoordinator & environment object define
@MainActor
final class AppCoordinator {
    let auth: AuthCoordinator
    let user: UserCoordinator
    let track: TrackCoordinator
    let setting: SettingCoordinator
    
    init(
        auth: AuthCoordinator = AuthCoordinator(),
        user: UserCoordinator = UserCoordinator(),
        track: TrackCoordinator = TrackCoordinator(),
        setting: SettingCoordinator = SettingCoordinator()
    ) {
        self.auth = auth
        self.user = user
        self.track = track
        self.setting = setting
    }
    
    // Append new routing coordinator here

    @ViewBuilder
    func rootView() -> some View {
        auth.destination(for: .login)
    }
}

private struct AppCoordinatorKey: EnvironmentKey {
    static let defaultValue: AppCoordinator? = nil
}

extension EnvironmentValues {
    var appCoordinator: AppCoordinator? {
        get { self[AppCoordinatorKey.self] }
        set { self[AppCoordinatorKey.self] = newValue }
    }
}
