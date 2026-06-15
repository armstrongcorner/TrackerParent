//
//  MainScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 24/04/2026.
//

import SwiftUI
import SwiftfulRouting

struct MainScreen: View {
    @Environment(SessionManager.self) private var sessionManager

    @State private var selection: CustomTabItem = .watchlist

    var body: some View {
        ZStack(alignment: .leading) {
            currentContent

            SideMenuView {
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 28,
                    topTrailingRadius: 28
                )
                .fill(Color.background)
            } menuContent: {
                sideMenuContent
            }
        }
    }
}

private extension MainScreen {
    @ViewBuilder
    var currentContent: some View {
        switch selection {
        case .watchlist:
            WatchListScreen(vm: WatchInvitationViewModel())
        case .tracks:
            placeholderScreen(title: "Tracks")
        case .settings:
            placeholderScreen(title: "Settings")
        }
    }

    var sideMenuContent: some View {
        let avatarColor = Color.color(for: sessionManager.authModel?.user?.id == nil ? UUID().uuidString : String(sessionManager.authModel?.user?.id ?? 0))
        
        return VStack(alignment: .leading, spacing: 12) {
//            Text("Menu")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .foregroundStyle(.primaryText)
//                .padding(.bottom, 8)
            
            Text(StringUtil.shared.initials(from: sessionManager.authModel?.user?.email ?? "").uppercased())
                .font(.title)
                .fontWeight(.bold)
                .padding([.vertical, .horizontal], 20)
                .background(
                    Circle()
                        .fill(avatarColor.opacity(0.2))
                )
                .overlay {
                    Circle()
                        .stroke(
                            .mainTheme.opacity(0.2),
                            style: StrokeStyle(lineWidth: 2)
                        )
                }
                .padding(.trailing, 5)
                .padding(.bottom, 25)

            menuItem(.watchlist)
            menuItem(.tracks)
            menuItem(.settings)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 48)
    }

    func menuItem(_ item: CustomTabItem) -> some View {
        Button {
            selection = item
            sessionManager.isShowingMenu = false
        } label: {
            HStack(spacing: 12) {
                Image(systemName: item.systemImageName)
                    .frame(width: 24, height: 24)

                Text(item.title.capitalized)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(selection == item ? item.activeFontColor : .primaryText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(selection == item ? item.activeBgColor : .clear)
            )
        }
        .buttonStyle(.plain)
    }

    func placeholderScreen(title: String) -> some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Button {
                    sessionManager.isShowingMenu = true
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(.mainTheme)
                }
                .buttonStyle(.plain)

                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primaryText)

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Previews
#Preview {
    let appCoordinator = AppCoordinator()
    mockSessionManager.updateAuthModel(AuthModel(accessToken: "", accessTokenExpiresAt: "", expiresIn: 0, refreshToken: "", user: UserModel(email: "armstrong.liu@matrixthoughts.com.au")), for: "armstrong.liu@matrixthoughts.com.au")

    return RouterView { _ in
        MainScreen()
    }
    .environment(\.appCoordinator, appCoordinator)
    .environment(mockSessionManager)
    .environment(ToastViewObserver())
}
