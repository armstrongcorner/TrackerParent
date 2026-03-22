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
    
    var body: some Scene {
        WindowGroup {
            RouterView { _ in
//                LoginScreen()
                MainScreen()
            }
            .environment(ToastViewObserver())
        }
    }
}
