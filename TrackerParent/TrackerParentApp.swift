//
//  TrackerParentApp.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 13/03/2025.
//

import SwiftUI
import SwiftfulRouting

@main
struct TrackerParentApp: App {
    var body: some Scene {
        WindowGroup {
            RouterView { _ in
                LoginScreen()
            }
            .environment(ToastViewObserver())
        }
    }
}
