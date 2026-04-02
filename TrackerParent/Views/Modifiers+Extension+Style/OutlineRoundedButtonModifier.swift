//
//  OutlineRoundedButtonModifier.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 08/03/2026.
//

import Foundation
import SwiftUI

struct OutlineRoundedButtonModifier: ViewModifier {
    let buttonHeight: CGFloat
    let buttonBackground: AnyShapeStyle
    let buttonTextColor: Color
    let outlineStyle: AnyShapeStyle
    let outlineWidth: CGFloat
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .foregroundStyle(buttonTextColor)
            .frame(height: buttonHeight)
            .background(buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(outlineStyle, lineWidth: outlineWidth)
            )
    }
}

extension View {
    func outlineRoundedButtonStyle(
        buttonHeight: CGFloat = 50,
        buttonBackground: AnyShapeStyle = AnyShapeStyle(Color.secondaryBackground),
        buttonTextColor: Color = Color.primaryText,
        outlineStyle: AnyShapeStyle = AnyShapeStyle(Color.outline),
        outlineWidth: CGFloat = 0.5,
        cornerRadius: CGFloat? = nil
    ) -> some View {
        modifier(OutlineRoundedButtonModifier(
            buttonHeight: buttonHeight,
            buttonBackground: buttonBackground,
            buttonTextColor: buttonTextColor,
            outlineStyle: outlineStyle,
            outlineWidth: outlineWidth,
            cornerRadius: cornerRadius ?? buttonHeight / 2
        ))
    }
}
