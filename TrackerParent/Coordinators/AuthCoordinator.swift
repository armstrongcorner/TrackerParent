//
//  AuthCoordinator.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 24/03/2026.
//

import SwiftUI

@MainActor
struct AuthCoordinator: RouteAction {
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
            LoginScreen()
        case .registerVerification:
            RegisterVerificationScreen()
        case .registerConfirmation(let registerViewModel):
            RegisterConfirmationScreen(registerViewModel: registerViewModel)
        case .postLogin(let role):
            switch role {
            case .admin:
                UserListScreen()
            case .user:
                TrackListScreen()
            }
        }
    }
}
