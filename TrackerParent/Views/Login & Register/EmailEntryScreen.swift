//
//  EmailEntryScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 09/04/2026.
//

import SwiftUI
import SwiftfulRouting

struct EmailEntryScreen: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.authViewModel) var vm: AuthViewModelProtocol?
    @Environment(\.router) private var router
    @Environment(\.appCoordinator) private var appCoordinator

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
                    
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.bottom, 5)
                    
                    titleSection
                        .padding(.bottom, 30)
                    
                    checkEmailSection
                        .padding(.bottom, 20)
                    
                    ZStack(alignment: .center) {
                        Divider()
                        
                        Text("OR")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondaryText.opacity(0.8))
                            .padding(.horizontal, 15)
                            .background(
                                Color.background
                            )
                    }
                    .padding(.bottom, 20)
                    
                    appleSignInBtn
                        .padding(.bottom, 8)
                    
                    googleSignInBtn
                        .padding(.bottom, 8)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 20)
            }
        }
        .onChange(of: vm?.emailFlowDestination) { _, newValue in
            switch newValue {
            case .login:
                appCoordinator?.auth.show(.emailLogin, on: router)
                vm?.emailFlowDestination = .none
            case .register(let flowToken):
                appCoordinator?.auth.show(.emailRegister(flowToken: flowToken), on: router)
                vm?.emailFlowDestination = .none
            default:
                vm?.emailFlowDestination = .none
            }
        }
    }
}

// MARK: - View sections
extension EmailEntryScreen {
    // Title section
    private var titleSection: some View {
        VStack {
            Text("Log in or sign up")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Enter your email to continue.")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.secondaryText)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    // Check email section
    private var checkEmailSection: some View {
        VStack {
            Text("Email address")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField(
                "",
                text: Binding(
                    get: { vm?.email ?? "" },
                    set: { vm?.email = $0 }
                ),
                prompt: Text(verbatim: "name@example.com")
                    .fontWeight(.regular)
            )
            .textFieldStyle(.plain)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.secondaryText)
            .clearButton(.constant(""))
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
                    await vm?.loginWithEmailStart()
                }
            } label: {
                HStack {
                    Text("Continue →")
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
                .shadow(color: .mainTheme, radius: 3, x: 0, y: 1)
            }
            .withPressableButtonStyle()
        }
    }

    // Apple sign in button
    private var appleSignInBtn: some View {
        Button {
            dismiss()
            vm?.autoTriggerAppleSignIn = true
        } label: {
            HStack {
                Image(systemName: "apple.logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                
                Text("Continue with Apple")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .outlineRoundedButtonStyle()
        }
        .withPressableButtonStyle()
    }
    
    // Google sign in button
    private var googleSignInBtn: some View {
        Button {
            dismiss()
            vm?.autoTriggerGoogleSignIn = true
        } label: {
            HStack {
                Image("google-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                
                Text("Continue with Google")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .outlineRoundedButtonStyle()
        }
        .withPressableButtonStyle()
    }
}

// MARK: - Previews
#Preview("Normal") {
    let mockUserDefaults = UserDefaults(suiteName: "au.com.matrixthoughts.TrackerParent.mock") ?? .standard
    
    let mockAuthViewModel = AuthViewModel(userDefaults: mockUserDefaults)
    
    return RouterView { _ in
        EmailEntryScreen()
            .environment(mockAuthViewModel)
    }
}
