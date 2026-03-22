//
//  PressableButtonStyle.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 08/03/2026.
//

import Foundation
import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    let scaleAmount: Double
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
    }
}

extension View {
    func withPressableButtonStyle(scaleAmount: Double = 0.9) -> some View {
        buttonStyle(PressableButtonStyle(scaleAmount: scaleAmount))
    }
}
