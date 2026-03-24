//
//  TrackCoordinator.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 24/03/2026.
//

import SwiftUI

@MainActor
struct TrackCoordinator: RouteAction {
    enum Route {
        case userList
        case trackList(username: String?)
        case trackDetail(track: [LocationModel])
    }

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .userList:
            UserListScreen()
        case .trackList(let username):
            TrackListScreen(username: username)
        case .trackDetail(let track):
            TrackDetailScreen(track: track)
        }
    }
}
