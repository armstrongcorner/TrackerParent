//
//  TrackerParentApp.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 13/03/2025.
//

import SwiftUI
import SwiftfulRouting
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseConfiguration.shared.setLoggerLevel(.debug)
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct TrackerParentApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    private let appCoordinator = AppCoordinator()
    @State private var sessionManager = SessionManager()
    @State private var toastViewObserver = ToastViewObserver()
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { proxy in
                RouterView { _ in
                    appCoordinator.rootView()
                }
                .toastView(toastViewObserver: toastViewObserver)
                .environment(\.appCoordinator, appCoordinator)
                .environment(AppSize(proxy.size))
                .environment(sessionManager)
                .environment(toastViewObserver)
            }
        }
    }
}
