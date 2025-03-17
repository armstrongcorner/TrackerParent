//
//  LoginScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 13/03/2025.
//

import SwiftUI

struct LoginScreen: View {
    @State private var authViewModel = AuthViewModel()
    
    var body: some View {
        VStack {
            // Username
            HStack {
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                   .padding(.trailing, 8)
                TextField("Username", text: $authViewModel.username)
                    .clearButton($authViewModel.username)
            }
            .padding([.leading, .trailing], 30)
            .padding(.bottom, 15)
            
            // Password
            HStack {
                Image(systemName: "lock.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                    .padding(.trailing, 8)
                SecureField("Password", text: $authViewModel.password)
                    .clearButton($authViewModel.password)
            }
            .padding([.leading, .trailing], 30)
            .padding(.bottom, 80)
            
            // Login btn
            Button {
                Task {
                    await authViewModel.login()
                }
            } label: {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 40)
                    .background(.primary)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
            
            // Login with faceID
            Button {
                //
            } label: {
                Image(systemName: "faceid")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60)
            }

        }
        .padding()
    }
}

#Preview {
    LoginScreen()
}
