//
//  SideMenuView.swift
//  HoMMPedia
//
//  Created by Armstrong Liu on 17/01/2025.
//

import SwiftUI

struct SideMenuView<MenuContent: View, MenuBackground: View>: View {
    @Environment(SessionManager.self) private var sessionManager
    
    let edgeTransition: AnyTransition
    let menuWidthRatio: CGFloat
    let menuCoverColor: Color
    let menuBackground: MenuBackground
    let menuContent: MenuContent
    
    init(
        edgeTransition: AnyTransition = .move(edge: .leading),
        menuWidthRatio: CGFloat = 2.0 / 3.0,
        menuCoverColor: Color = .black.opacity(0.3),
        @ViewBuilder menuBackground: () -> MenuBackground = { Color.white },
        @ViewBuilder menuContent: () -> MenuContent
    ) {
        self.edgeTransition = edgeTransition
        self.menuWidthRatio = menuWidthRatio
        self.menuCoverColor = menuCoverColor
        self.menuBackground = menuBackground()
        self.menuContent = menuContent()
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                if sessionManager.isShowingMenu {
                    menuCoverColor
                        .onTapGesture {
                            sessionManager.isShowingMenu.toggle()
                        }
                    
                    menuContent
                        .transition(edgeTransition)
                        .frame(
                            width: proxy.size.width * menuWidthRatio,
                            height: proxy.size.height
                        )
                        .background(menuBackground)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .animation(.easeInOut, value: sessionManager.isShowingMenu)
        }
        .ignoresSafeArea(.all)
    }
}

// MARK: - Previews
#Preview("Custom") {
    SideMenuView {
        UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 30,
            topTrailingRadius: 30
        )
        .fill(Color.background)
    } menuContent: {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile")
            Text("Settings")
            Text("Logout")
        }
        .padding()
    }
    .environment(SessionManager(isShowingMenu: true))
}

#Preview("Default") {
    SideMenuView {
        VStack(alignment: .leading, spacing: 16) {
            Text("Profile")
            Text("Settings")
            Text("Logout")
        }
        .padding()
    }
    .environment(SessionManager(isShowingMenu: true))
}
