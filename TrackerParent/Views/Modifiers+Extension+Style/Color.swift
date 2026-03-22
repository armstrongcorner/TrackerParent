//
//  Color.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 07/03/2026.
//

import Foundation
import SwiftUI

extension Color {
    static let theme = ColorTheme()
}

struct ColorTheme {
    let background = Color("BackgroundColor")
    let secondaryBackground = Color("SecondaryBackgroundColor")
    let reverseBackground = Color("ReverseBackgroundColor")
    let primaryText = Color("PrimaryTextColor")
    let outline = Color("OutlineColor")
}
