//
//  LoginScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 21/03/2026.
//

import SwiftUI
import MTAuthHelper
import SwiftfulRouting

struct LoginScreen: View {
    @Environment(\.router) private var router
    @Environment(ToastViewObserver.self) private var toastViewObserver
    @State private var vm: AuthViewModel
    
    init(vm: AuthViewModel = AuthViewModel()) {
        _vm = State(wrappedValue: vm)
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
        .onChange(of: vm.loginState) { _, newValue in
            switch newValue {
            case .none:
                toastViewObserver.dismissLoading()
            case .loading:
                toastViewObserver.showLoading()
            case .success:
                toastViewObserver.dismissLoading()
                router.showScreen(.push) { _ in
                    loginSuccessSection
                }
            case .failure:
                toastViewObserver.dismissLoading()
                if let errMsg = vm.errMsg {
                    toastViewObserver.showToast(message: errMsg)
                }
            }
        }
        .toastView(toastViewObserver: toastViewObserver)
    }
}

// MARK: - SignIn button section
extension LoginScreen {
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
            router.showScreen(.push) { _ in
                RegisterVerificationScreen()
            }
        } label: {
            HStack {
                Image(systemName: "lock.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23, height: 23)
                
                Text("Login or Sign Up")
                    .font(.headline)
            }
            .outlineRoundedButtonStyle()
            
        }
        .withPressableButtonStyle()
    }
}

extension LoginScreen {
    @ViewBuilder
    private var loginSuccessSection: some View {
        if vm.role == "Administrator" {
            UserListScreen()
        } else if vm.role == "User" {
            TrackListScreen()
        } else {
            EmptyView()
        }
    }
}

// MARK: - Previews
#Preview {
    RouterView { _ in
        LoginScreen()
    }
    .environment(ToastViewObserver())
}
