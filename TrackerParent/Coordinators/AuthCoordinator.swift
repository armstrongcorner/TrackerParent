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
        case emailRegister(vm: AuthViewModelProtocol, flowToken: String)
        case emailLogin(vm: AuthViewModelProtocol, flowToken: String)
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
        case .emailRegister(let vm, let flowToken):
            EmailRegisterScreen(flowToken: flowToken)
                .environment(\.authViewModel, vm)
        case .emailLogin(let vm, let flowToken):
            EmailLoginScreen(flowToken: flowToken)
                .environment(\.authViewModel, vm)
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
