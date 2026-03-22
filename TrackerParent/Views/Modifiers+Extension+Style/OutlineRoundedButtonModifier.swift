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
    let buttonColor: Color
    let buttonTextColor: Color
    let outlineColor: Color
    let outlineWidth: CGFloat
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
//            .foregroundStyle(Color.primaryText)
//            .frame(maxWidth: .infinity)
//            .frame(height: 50)
//            .background(Color.secondaryBackground)
//            .clipShape(RoundedRectangle(cornerRadius: 25))
//            .overlay(
//                RoundedRectangle(cornerRadius: 25)
//                    .stroke(Color.outline, lineWidth: 0.5)
//            )
            .foregroundStyle(buttonTextColor)
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .background(buttonColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(outlineColor, lineWidth: outlineWidth)
            )
    }
}

extension View {
    func outlineRoundedButtonStyle(
        buttonHeight: CGFloat = 50,
        buttonColor: Color = Color.secondaryBackground,
        buttonTextColor: Color = Color.primaryText,
        outlineColor: Color = Color.outline,
        outlineWidth: CGFloat = 0.5,
        cornerRadius: CGFloat? = nil
    ) -> some View {
        modifier(OutlineRoundedButtonModifier(
            buttonHeight: buttonHeight,
            buttonColor: buttonColor,
            buttonTextColor: buttonTextColor,
            outlineColor: outlineColor,
            outlineWidth: outlineWidth,
            cornerRadius: cornerRadius ?? buttonHeight / 2))
    }
}
