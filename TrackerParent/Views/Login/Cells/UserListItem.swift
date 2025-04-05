//
//  UserListItem.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 05/04/2025.
//

import SwiftUI

struct UserListItem: View {
    let user: UserModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Username: \(user.userName ?? "")")
                
                Spacer()
            }
            
            HStack {
                Text("Role: \(user.role ?? "")")
                
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    Group {
        UserListItem(user: mockUser1)
        UserListItem(user: mockUser2)
    }
}
