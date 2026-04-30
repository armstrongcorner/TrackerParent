//
//  CustomTabBar.swift
//  AdvancedLearning
//
//  Created by Armstrong Liu on 25/12/2025.
//

import SwiftUI

struct CustomTabBar: View {
    @Namespace private var namespace
    let tabs: [CustomTabItem]
    @Binding var selection: CustomTabItem?
    
    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tabItem in
                tabBarItem(tabItem)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            selection = tabItem
                        }
                    }
            }
        }
        .padding(10)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 20.0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 20.0
            )
            .fill(.reversePrimaryText)
            .ignoresSafeArea(edges: .bottom)
        )
    }
}

extension CustomTabBar {
    func tabBarItem(_ tabBarItem: CustomTabItem) -> some View {
        VStack(spacing: 8) {
            Image(systemName: tabBarItem.systemImageName)
                .font(.title)
            
            Text(tabBarItem.title)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(selection == tabBarItem ? tabBarItem.activeFontColor : .gray)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                if selection == tabBarItem {
                    Capsule()
                        .fill(tabBarItem.activeBgColor)
                        .matchedGeometryEffect(id: "tabBar", in: namespace)
                }
            }
        )
    }
}

#Preview {
    Group {
        let mockTabs: [CustomTabItem] = [ .watchlist, .tracks, .settings ]
        
        CustomTabBar(tabs: mockTabs, selection: .constant(.settings))
    }
}
