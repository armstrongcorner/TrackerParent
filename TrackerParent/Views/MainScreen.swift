//
//  MainScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 07/03/2026.
//

import SwiftUI
import Combine
import MTAuthHelper

struct MainScreen<VM: AuthViewModelProtocol & ObservableObject>: View {
    @StateObject private var vm: VM
    
    init(vm: VM = AuthViewModel()) {
        _vm = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                
                buttonSection
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - SignIn button section
extension MainScreen {
    private var buttonSection: some View {
        VStack(spacing: 13) {
            appleSignInBtn
                                
            googleSignInBtn
            
            emailSignInBtn
        }
        .padding(.horizontal)
    }

    // MARK: Apple sign in button
    private var appleSignInBtn: some View {
        Button {
            Task {
                await vm.loginWithSSO(type: .apple)
            }
        } label: {
            HStack {
                Image(systemName: "apple.logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                
                Text("Continue with Apple")
                    .font(.headline)
            }
            .outlineRoundedButtonStyle()
        }
        .withPressableButtonStyle()
    }
    
    // MARK: Google sign in button
    private var googleSignInBtn: some View {
        Button {
            Task {
                await vm.loginWithSSO(type: .google)
            }
        } label: {
            HStack {
                Image("google-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                
                Text("Continue with Google")
                    .font(.headline)
            }
            .outlineRoundedButtonStyle()
        }
        .withPressableButtonStyle()
    }
    
    // MARK: Email sign in button
    private var emailSignInBtn: some View {
        Button {
            
        } label: {
            HStack {
                Image(systemName: "lock.fill")
                Text("Login or Sign Up")
            }
            .outlineRoundedButtonStyle()
            
        }
        .withPressableButtonStyle()
    }
}

#Preview {
    MainScreen()
}
