//
//  Color.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 07/03/2026.
//

import Foundation
import SwiftUI

private let dotColors: [Color] = [.green, .blue, .orange, .pink, .red, .yellow]

extension Color {
    static let theme = ColorTheme()
    
    static func color(for id: String) -> Color {
        let index = abs(id.hashValue) % dotColors.count
        return dotColors[index]
    }
}

struct ColorTheme {
    let background = Color("BackgroundColor")
    let secondaryBackground = Color("SecondaryBackgroundColor")
    let reverseBackground = Color("ReverseBackgroundColor")
    let primaryText = Color("PrimaryTextColor")
    let reversePrimaryText = Color("ReversePrimaryTextColor")
    let outline = Color("OutlineColor")
    let mainTheme = Color("MainThemeColor")
    let secondaryText = Color("SecondaryTextColor")
    let textFieldBg = Color("TextFieldBgColor")
    let importantTip = Color("ImportantTipColor")
}
