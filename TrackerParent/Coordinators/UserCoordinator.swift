//
//  UserCoordinator.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 27/03/2026.
//

import SwiftUI

@MainActor
struct UserCoordinator: RouteAction {
    enum Route {
        case sendInvitation(AnyView)
        case invitationHistory(AnyView)
    }

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .sendInvitation(let sendInvitationScreen):
            sendInvitationScreen
        case .invitationHistory(let invitationHistoryScreen):
            invitationHistoryScreen
        }
    }
}
