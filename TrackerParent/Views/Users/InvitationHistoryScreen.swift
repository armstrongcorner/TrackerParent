//
//  InvitationHistoryScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 01/04/2026.
//

import SwiftUI
import SwiftfulRouting

struct InvitationHistoryScreen<VM: WatchInvitationViewModelProtocol>: View {
//    @Environment(\.router) private var router
    @Bindable var vm: VM
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack {
                Text("Invitation History")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if vm.invitations.isEmpty {
                    emptyInvitationListView
                } else {
                    // Invitation list view
                    invitationListContentView
                        .padding(.vertical, 15)
                }
            }
            .padding(.horizontal)
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
        EmptyView()
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
