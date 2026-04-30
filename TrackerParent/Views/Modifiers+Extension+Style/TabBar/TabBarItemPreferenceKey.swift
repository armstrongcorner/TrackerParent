//
//  TabBarItemPreferenceKey.swift
//  AdvancedLearning
//
//  Created by Armstrong Liu on 26/12/2025.
//

import Foundation
import SwiftUI

struct TabBarItemPreferenceKey: PreferenceKey {
    static let defaultValue: [CustomTabItem] = []
    
    static func reduce(value: inout [CustomTabItem], nextValue: () -> [CustomTabItem]) {
        value.append(contentsOf: nextValue())
    }
}

struct CustomTabBarItemModifier: ViewModifier {
    let tab: CustomTabItem
    @Binding var selection: CustomTabItem?
    
    func body(content: Content) -> some View {
        content
            .opacity(selection == tab ? 1 : 0)
            .preference(key: TabBarItemPreferenceKey.self, value: [tab])
    }
}

extension View {
    func customTabItem(_ tab: CustomTabItem, selection: Binding<CustomTabItem?>) -> some View {
        self.modifier(CustomTabBarItemModifier(tab: tab, selection: selection))
    }
}
