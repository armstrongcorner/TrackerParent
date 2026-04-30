//
//  CustomTabItem.swift
//  AdvancedLearning
//
//  Created by Armstrong Liu on 25/12/2025.
//

import Foundation
import SwiftUI

enum CustomTabItem: Hashable {
    case watchlist, tracks, settings
    
    var systemImageName: String {
        switch self {
        case .watchlist: "eye.fill"
        case .tracks: "mappin.and.ellipse.circle.fill"
        case .settings: "gearshape.fill"
        }
    }
    
    var title: String {
        switch self {
        case .watchlist: "WATCHLIST"
        case .tracks: "TRACKS"
        case .settings: "SETTINGS"
        }
    }
    
    var activeBgColor: Color {
        .outline.opacity(0.3)
    }
    
    var activeFontColor: Color {
        .mainTheme
    }
}
