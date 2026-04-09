//
//  AuthCoordinator.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 24/03/2026.
//

import SwiftUI

@MainActor
final class AuthCoordinator: RouteAction {
    let authViewModel: AuthViewModelProtocol
    
    init(authViewModel: AuthViewModelProtocol) {
        self.authViewModel = authViewModel
    }
    
    enum Route {
        case login
        case registerVerification
        case registerConfirmation(registerViewModel: RegisterViewModelProtocol)
        case postLogin(role: AccountRole)
    }

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .login:
            LoginScreen(vm: authViewModel)
        case .registerVerification:
            RegisterVerificationScreen()
        case .registerConfirmation(let registerViewModel):
            RegisterConfirmationScreen(registerViewModel: registerViewModel)
        case .postLogin(let role):
            switch role {
            case .admin:
                UserListScreen()
            case .user:
                WatchListScreen()
            }
        }
    }
}
