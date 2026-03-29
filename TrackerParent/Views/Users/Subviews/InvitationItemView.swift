//
//  InvitationItemView.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 29/03/2026.
//

import SwiftUI

struct InvitationItemView: View {
    let invitation: PendingInvitationEntity
    
    init(_ invitation: PendingInvitationEntity) {
        self.invitation = invitation
    }
    
    var body: some View {
        let avatarColor = Color.color(for: invitation.id)
        
        HStack {
            Text(invitation.displayName.uppercased())
                .padding([.vertical, .horizontal], 13)
                .background(
                    Circle()
                        .fill(avatarColor.opacity(0.2))
                        .shadow(
                            color: avatarColor,
                            radius: 2,
                            x: 0, y: 0
                        )
                )
                .padding(.trailing, 5)
            
            Text("\(invitation.email)")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.secondaryText)
            
            Spacer()
        }
    }
}

#Preview {
    Group {
        InvitationItemView(PendingInvitationEntity(
            id: UUID().uuidString,
            displayName: "ab",
            email: "a.b@example.com"
        ))
        
        InvitationItemView(PendingInvitationEntity(
            id: UUID().uuidString,
            displayName: "js",
            email: "jack.sparrow@example.com"
        ))
        
        InvitationItemView(PendingInvitationEntity(
            id: UUID().uuidString,
            displayName: "ws",
            email: "william.spike@example.com"
        ))
    }
}
