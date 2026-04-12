//
//  AuthCoordinator.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 24/03/2026.
//

import SwiftUI

@MainActor
final class AuthCoordinator: RouteAction {
    enum Route {
        case login
        case emailEntry(vm: AuthViewModelProtocol)
        case emailRegister(flowToken: String)
        case emailLogin
        
        case registerVerification
        case registerConfirmation(registerViewModel: RegisterViewModelProtocol)
        case postLogin(role: AccountRole)
    }

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .login:
            LoginScreen(vm: AuthViewModel())
        case .emailEntry(let vm):
            EmailEntryScreen()
                .environment(\.authViewModel, vm)
        case .emailRegister(flowToken: let flowToken):
            EmailRegisterScreen(flowToken: flowToken)
        case .emailLogin:
            EmailLoginScreen()
            
        case .registerVerification:
            RegisterVerificationScreen()
        case .registerConfirmation(let registerViewModel):
            RegisterConfirmationScreen(registerViewModel: registerViewModel)
        case .postLogin(let role):
            switch role {
            case .admin:
                UserListScreen()
            case .user:
                WatchListScreen(vm: WatchInvitationViewModel())
            }
        }
    }
}
