//
//  CustomTabView.swift
//  AdvancedLearning
//
//  Created by Armstrong Liu on 25/12/2025.
//

import SwiftUI

struct CustomTabView<TabContent: View>: View {
    @Binding var selection: CustomTabItem?
    let content: TabContent
    @State private var tabs: [CustomTabItem] = []
    
    init(selection: Binding<CustomTabItem?>, @ViewBuilder content: () -> TabContent) {
        self._selection = selection
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            content
            CustomTabBar(tabs: tabs, selection: $selection)
        }
        
        .onPreferenceChange(TabBarItemPreferenceKey.self) { value in
            self.tabs = value
        }
    }
}

#Preview {
    let mockTabs: [CustomTabItem] = [.watchlist, .tracks, .settings]
    
    CustomTabView(selection: .constant(mockTabs.first)) {
        Color.orange
    }
}
