//
//  WatchListScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 25/03/2026.
//

import SwiftUI
import SwiftfulRouting

struct WatchListScreen<VM: WatchInvitationViewModelProtocol>: View {
    @Environment(\.router) private var router
    @Environment(\.appCoordinator) private var appCoordinator
    @Environment(ToastViewObserver.self) private var toastViewObserver
    @Environment(SessionManager.self) private var sessionManager
    
    @State private var vm: VM
    
    init(vm: VM = WatchInvitationViewModel()) {
        _vm = State(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Active Monitors")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !vm.watchList.isEmpty {
                    Text("Select a primary account to track in real-time")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if vm.watchList.isEmpty {
                    emptyWatchListView
                } else {
                    // Watch list view
                    watchListContentView
                        .padding(.vertical, 15)
                }
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden()
        .task {
            if vm.initialRefresh {
                await vm.fetchInvitationsAndWatchedUserList()
                let _ = print(vm.invitations.count)
                let _ = print(vm.watchList.count)
            }
        }
        .onChange(of: vm.showAddWatchSheet) { _, newValue in
            if newValue {
                navigateToSendInvitation()
            }
        }
    }
}

// MARK: - View sections
extension WatchListScreen {
    // Watch list empty content view
    private var emptyWatchListView: some View {
        Group {
            Spacer()
            
            VStack {
                Image(systemName: "eye.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.mainTheme)
                    .frame(width: 50, height: 50)
                    .padding(30)
                    .background(
                        Circle()
                            .fill(.reversePrimaryText)
                    )
                    .overlay {
                        Circle()
                            .stroke(
                                .primaryText.opacity(0.1),
                                lineWidth: 0.5
                            )
                    }
                    .padding(.bottom, 30)
                
                Text("No active monitors yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
                
                Text("Add a user to start tracking their location and activity status in real-time across you dashboard.")
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 30)
                
                invitateUserButton
                
                invitationHistoryButton
                    .padding(.top, 20)
            }
            .padding(35)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.outline.opacity(0.2))
                    .overlay {
                        Circle()
                            .stroke(
                                .mainTheme.opacity(0.3),
                                style: StrokeStyle(lineWidth: 1.0, dash: [12, 10])
                            )
                            .padding(30)
                    }
                    .overlay {
                        Circle()
                            .stroke(
                                .mainTheme.opacity(0.3),
                                style: StrokeStyle(lineWidth: 1.0, dash: [12, 10])
                            )
                            .padding(70)
                    }
                    .overlay {
                        Circle()
                            .stroke(
                                .mainTheme.opacity(0.3),
                                lineWidth: 1.0
                            )
                            .padding(110)
                    }
            )
            .padding()
            
            Spacer()
            
            Spacer()
        }
    }
    
    // Watch list content view
    private var watchListContentView: some View {
        Group {
            List {
                ForEach(vm.watchList, id: \.self) { watchRelationship in
                    WatchedUserView(
                        watchRelationship,
                        isSelected: watchRelationship.id == sessionManager.currentWatchRelationshipId
                    )
                    .onTapGesture {
                        if watchRelationship.id != sessionManager.currentWatchRelationshipId {
                            markAsCurrentWatchAction(relationshipId: watchRelationship.id ?? 0)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            
            invitateUserButton
            
            invitationHistoryButton
        }
    }
    
    // Invite user button
    private var invitateUserButton: some View {
        Button {
            vm.showAddWatchSheet = true
        } label: {
            HStack {
                Image(systemName: "person.fill.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.reversePrimaryText)
                    .frame(width: 25, height: 25)
                
                Text("Invite User")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .outlineRoundedButtonStyle(
                buttonBackground: AnyShapeStyle(
                    LinearGradient(
                        colors: [.mainTheme, .mainTheme.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing)
                ),
                buttonTextColor: .white,
                outlineWidth: 0
            )
            .shadow(color: .mainTheme, radius: 3, x: 0, y: 3)
        }
        .withPressableButtonStyle()
    }
    
    // View invitation history button
    private var invitationHistoryButton: some View {
        Button {
            navigateToInvitationHistory()
        } label: {
            Text("View Invitation History  >")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(.mainTheme)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .withPressableButtonStyle()
    }
}

// MARK: - Navigations & other functions
extension WatchListScreen {
    private func navigateToSendInvitation() {
        let config = ResizableSheetConfig(
            detents: [.fraction(0.8), .large],
            dragIndicator: .automatic,
            backgroundInteraction: .disabled
        )
        appCoordinator?.user.show(
            .sendInvitation(AnyView(SendInvitationScreen(vm: vm))),
            on: router,
            sheetConfig: config) { [weak vm] in
                guard let vm else { return }
                vm.showAddWatchSheet = false
            }
    }
    
    private func navigateToInvitationHistory() {
        appCoordinator?.user.show(.invitationHistory(AnyView(InvitationHistoryScreen(vm: vm))), on: router)
    }
    
    private func markAsCurrentWatchAction(relationshipId: Int) {
        Task {
            await vm.markAsCurrentWatch(relationshipId: relationshipId, sessionManger: sessionManager)
        }
    }
}

// MARK: - Previews
#Preview("Normal") {
    let mockVM = MockWatchInvitationViewModel()
    mockSessionManager.updateAuthModel(mockAuth2, for: "test_username2@example.com")
    
    return RouterView { _ in
        WatchListScreen(vm: mockVM)
    }
    .environment(mockSessionManager)
    .environment(ToastViewObserver())
}

#Preview("Empty invitations & watch list") {
    let mockVM = MockWatchInvitationViewModel(shouldReturnEmptyData: true)

    RouterView { _ in
        WatchListScreen(vm: mockVM)
    }
    .environment(mockSessionManager)
    .environment(ToastViewObserver())
}
