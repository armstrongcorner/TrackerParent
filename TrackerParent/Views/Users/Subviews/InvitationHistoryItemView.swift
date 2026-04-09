//
//  InvitationHistoryItemView.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 02/04/2026.
//

import SwiftUI

struct InvitationHistoryItemView: View {
    let invitation: InvitationModel
    
    init(_ invitation: InvitationModel) {
        self.invitation = invitation
    }
    
    var body: some View {
        let avatarColor = Color.color(for: invitation.id == nil ? UUID().uuidString : String(invitation.id ?? 0))
        var statusColor: Color = .warning
        switch invitation.status {
        case .pending:
            statusColor = .importantTip
        case .accepted:
            statusColor = .lightLime
        default:
            statusColor = .warning
        }
        
        return VStack(alignment: .leading, spacing: 30) {
            HStack {
                // Avatar
                Text(StringUtil.shared.initials(from: (invitation.inviteeEmail ?? "")).uppercased())
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
                
                // Email & sent datetime
                VStack(alignment: .leading) {
                    Text(invitation.inviteeEmail ?? "")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image(systemName: "clock")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        
                        Text(DateUtil.shared.convertStandardDateTimeStr(
                            iso8601String: invitation.createdAt ?? "",
                            targetDataFormatStr: "MMM d, yyyy, h:mm a"
                        ) ?? "")
                        .font(.callout)
                        .fontWeight(.regular)
                        .foregroundStyle(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            
            
            // Status & actions
            HStack {
                Text(invitation.status?.rawValue.uppercased() ?? "")
                    .statusLabelStyle(themeColor: statusColor)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(Angle(degrees: 90))
                        .foregroundStyle(.secondaryText)
                        .bold()
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.reversePrimaryText)
        )
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(
            EdgeInsets(
                top: 6,
                leading: 0,
                bottom: 13,
                trailing: 0
            )
        )
    }
}

// MARK: - Previews
#Preview {
    ZStack {
        Color.background.ignoresSafeArea()
        
        VStack {
            InvitationHistoryItemView(mockInvitation1)
            
            InvitationHistoryItemView(mockInvitation2)
        }
    }
}
