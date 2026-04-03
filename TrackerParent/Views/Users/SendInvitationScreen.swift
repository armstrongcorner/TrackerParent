//
//  SendInvitationScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 27/03/2026.
//

import SwiftUI

struct SendInvitationScreen<VM: WatchInvitationViewModelProtocol>: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var vm: VM
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.outline)
                            .frame(width: 20, height: 20)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    titleSection
                        .padding(.bottom, 30)
                    
                    sendInvitationSection
                        .padding(.bottom, 30)
                    
                    pendingInvitationsSection
                        .padding(.bottom, 30)
                    
                    tipSection
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
            }
        }
    }
}

// MARK: - View sections
extension SendInvitationScreen {
    // Title section
    private var titleSection: some View {
        VStack {
            Text("Add Account to Watch")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Enter email of the team member you wish to monitor.")
                .font(.headline)
                .fontWeight(.regular)
                .foregroundStyle(.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // Send invitation section
    private var sendInvitationSection: some View {
        VStack {
            Text("Invitee Email Address")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                Image(systemName: "envelope.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondaryText)
                    .frame(width: 25, height: 25)
                
                TextField(
                    "",
                    text: $vm.email,
                    prompt: Text(verbatim: "e.g. john.smith@teamname.com")
                        .fontWeight(.regular)
                )
                .textFieldStyle(.plain)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondaryText)
                .clearButton($vm.email)
            }
            .padding()
            .background(
                Capsule()
                    .fill(.textFieldBg)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        .outline,
                        lineWidth: 0.3
                    )
            }
            .padding(.bottom, 10)
            
            Button {
                Task {
                    await vm.sendInvitation()
                }
            } label: {
                HStack {
                    Text("Send Invitation")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .outlineRoundedButtonStyle(
                    buttonBackground: AnyShapeStyle(
                        LinearGradient(
                            colors: [.mainTheme, .mainTheme.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing)
                    ),
                    buttonTextColor: .white,
                    outlineWidth: 0
                )
                .shadow(color: .mainTheme, radius: 5, x: 0, y: 3)
            }
            .withPressableButtonStyle()
        }
    }
    
    // Pending invitations section
    private var pendingInvitationsSection: some View {
        VStack {
            HStack {
                Text("PENDING INVITATIONS")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondaryText)
                
                Spacer()
                
                Text("\(vm.pendingInvitationList.count) Sent")
                    .foregroundStyle(.mainTheme)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(.mainTheme.opacity(0.2))
                    )
            }
            .padding(.bottom, 10)
            
            // Invitation list
            if vm.pendingInvitationList.isEmpty {
                emptyListView
            } else {
                invitationListView
            }
        }
    }
    
    // Tip section
    private var tipSection: some View {
        HStack(alignment: .top) {
            Image(systemName: "exclamationmark.circle")
                .fontWeight(.bold)
                .foregroundStyle(.importantTip)
                .padding(.top, 5)
            
            Text("Privacy consent will be requested from the target account. They must manually approve your request before location sharing begins.")
                .font(.subheadline)
                .foregroundStyle(.secondaryText)
                .italic()
                .multilineTextAlignment(.leading)
        }
    }
}

// MARK: - Other subviews
extension SendInvitationScreen {
    private var emptyListView: some View {
        VStack {
            Image(systemName: "envelope.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.mainTheme)
                .frame(width: 40, height: 40)
                .padding(25)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.outline.opacity(0.5))
                )
                .padding(.vertical, 15)
            
            Text("No Invitation Sent")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 5)
            
            Text("Send your first request to start tracking a team member's location.")
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundStyle(.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 40)
                .padding(.bottom, 15)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 30.0)
                .fill(.textFieldBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30.0)
                .stroke(
                    .outline,
                    style: vm.pendingInvitationList.count > 0 ? StrokeStyle(lineWidth: 2) : StrokeStyle(lineWidth: 2, dash: [10, 5])
                )
        )
    }
    
    private var invitationListView: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(vm.pendingInvitationList, id: \.id) { invitation in
                    InvitationItemView(invitation)
                }
            }
        }
        .scrollIndicators(.hidden)
        .frame(height: 228)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 30.0)
                .fill(.textFieldBg)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(
                    .outline,
                    style: StrokeStyle(lineWidth: 0.2)
                )
        )
    }
}

// MARK: - Previews
#Preview("Normal") {
    let vm = MockWatchInvitationViewModel()
    vm.pendingInvitationList.append(contentsOf: [
        PendingInvitationEntity(id: "1", displayName: "jd", email: "john.doe@example.com", message: ""),
        PendingInvitationEntity(id: "2", displayName: "ah", email: "amber.heard@example.com", message: ""),
    ])
    
    return SendInvitationScreen(vm: vm)
}

#Preview("Empty list") {
    SendInvitationScreen(vm: MockWatchInvitationViewModel())
}
