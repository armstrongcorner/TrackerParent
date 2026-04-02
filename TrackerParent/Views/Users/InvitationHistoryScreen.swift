//
//  InvitationHistoryScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 01/04/2026.
//

import SwiftUI
import SwiftfulRouting

struct InvitationHistoryScreen<VM: WatchInvitationViewModelProtocol>: View {
    @Environment(\.router) private var router
    @Environment(\.appCoordinator) private var appCoordinator
    @Bindable var vm: VM
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    Text("Invitation History")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if !vm.invitations.isEmpty {
                        Text("View and manage requests sent to your team members and collaborators.")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if vm.invitations.isEmpty {
                        emptyInvitationListView
                    } else {
                        // Invitation list view
                        invitationListContentView
                            .padding(.vertical, 15)
                    }
                }
                .padding(.horizontal)
                
                invitateUserButton
            }
            .onChange(of: vm.showAddWatchSheet) { _, newValue in
                if newValue {
                    navigateToSendInvitation()
                }
            }
        }
    }
}

// MARK: - Views
extension InvitationHistoryScreen {
    // Invitation list empty content view
    private var emptyInvitationListView: some View {
        Group {
            Spacer()
            
            VStack {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .rotationEffect(Angle(degrees: 45))
                    .foregroundStyle(.lightLime.opacity(0.7))
                    .frame(width: 40, height: 40)
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.outline.opacity(0.3))
                    )
                    .padding(.bottom, 30)
                
                Text("No invitations sent")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primaryText)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
                
                Text("Your history will appear here once you've invited team members or collaborators to your watchlist.")
                    .font(.title3)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondaryText)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 30)
                
                HStack(alignment: .center, spacing: 15) {
                    HStack(spacing: -12) {
                        ForEach(0..<3) { index in
                            Circle()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(circleColor(for: index))
                                .overlay {
                                    Circle()
                                        .stroke(.reversePrimaryText, lineWidth: 1)
                                }
                                .zIndex(Double(index))
                        }
                    }
                    
                    Text("Total invitations: 0")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.mainTheme)
                }
            }
            .padding(35)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(.reversePrimaryText)
                    .overlay {
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(
                                .outline.opacity(0.3),
                                lineWidth: 0.5
                            )
                    }
            )
            .padding()
            
            Spacer()
            
            Spacer()
        }
    }
    
    // Invitation list content view
    private var invitationListContentView: some View {
        List {
            ForEach(vm.invitations, id: \.self) { invitation in
                InvitationHistoryItemView(invitation)
            }
        }
        .listStyle(.plain)
        .scrollIndicators(.hidden)
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
            .padding(.horizontal, 30)
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
            .padding(.horizontal, 30)
        }
        .withPressableButtonStyle()
    }
}

// MARK: - Navigations & other functions
extension InvitationHistoryScreen {
    private func navigateToSendInvitation() {
        let config = ResizableSheetConfig(
            detents: [.fraction(0.8), .large],
            dragIndicator: .automatic,
            backgroundInteraction: .disabled
        )
        appCoordinator.user.show(
            .sendInvitation(AnyView(SendInvitationScreen(vm: vm))),
            on: router,
            sheetConfig: config) { [weak vm] in
                vm?.showAddWatchSheet = false
            }
    }
    
    private func circleColor(for index: Int) -> Color {
        switch index {
        case 0: return Color(uiColor: .systemGray6)
        case 1: return Color(uiColor: .systemGray5)
        default: return Color(uiColor: .systemGray4)
        }
    }
}

// MARK: - Previews
#Preview("Normal") {
    let mockVM = MockWatchInvitationViewModel()
    
    return RouterView { _ in
        InvitationHistoryScreen(vm: mockVM)
            .task {
                await mockVM.fetchInvitationsAndWatchedUserList()
            }
    }
    .environment(ToastViewObserver())
}

#Preview("Empty invitations") {
    let mockVM = MockWatchInvitationViewModel(shouldReturnEmptyData: true)

    return RouterView { _ in
        InvitationHistoryScreen(vm: mockVM)
    }
    .environment(ToastViewObserver())
}
