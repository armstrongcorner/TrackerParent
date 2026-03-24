//
//  SettingCoordinator.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 24/03/2026.
//

import SwiftUI
import SwiftfulRouting

@MainActor
struct SettingCoordinator: RouteAction {
    enum Route {
        case settingList
        case settingDetail(settingViewModel: SettingViewModelProtocol, isNewSetting: Bool)
    }

    @ViewBuilder
    func destination(for route: Route) -> some View {
        switch route {
        case .settingList:
            SettingListScreen()
        case .settingDetail(let settingViewModel, let isNewSetting):
            SettingDetailScreen(settingViewModel: settingViewModel, isNewSetting: isNewSetting)
        }
    }

    func show(_ route: Route, on router: AnyRouter, horizontalSizeClass: UserInterfaceSizeClass? = nil) {
        switch route {
        case .settingList:
            show(route, on: router, segue: .push)
        case .settingDetail:
            let config = ResizableSheetConfig(
                detents: [.fraction(horizontalSizeClass == .compact ? 0.5 : 0.7)],
                selection: nil,
                dragIndicator: .visible
            )
            show(route, on: router, sheetConfig: config)
        }
    }
}
