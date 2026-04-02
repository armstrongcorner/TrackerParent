//
//  StatusLabelModifier.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 03/04/2026.
//

import SwiftUI

struct StatusLabelModifier: ViewModifier {
    let paddingHorizontal: CGFloat
    let paddingVertical: CGFloat
    let themeColor: Color
    let bgColor: Color
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(themeColor)
            .padding(.horizontal, paddingHorizontal)
            .padding(.vertical, paddingVertical)
            .background(bgColor)
            .clipShape(
                Capsule()
            )
    }
}

extension View {
    func statusLabelStyle(
        paddingHorizontal: CGFloat = 20,
        paddingVertical: CGFloat = 10,
        themeColor: Color = .mainTheme,
        bgColor: Color? = nil
    ) -> some View {
        modifier(StatusLabelModifier(
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            themeColor: themeColor,
            bgColor: bgColor ?? themeColor.opacity(0.1)
        ))
    }
}

#Preview {
    Group {
        Text("STATUS")
            .statusLabelStyle()
        
        Text("Different")
            .statusLabelStyle(
                themeColor: .importantTip
            )
        
        Text("Custom")
            .statusLabelStyle(
                themeColor: .red,
                bgColor: .outline.opacity(0.3)
            )
    }
}
