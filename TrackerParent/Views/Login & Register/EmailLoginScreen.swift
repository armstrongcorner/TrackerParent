//
//  EmailLoginScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 11/04/2026.
//

import SwiftUI
import SwiftfulRouting

struct EmailLoginScreen: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.authViewModel) var vm: AuthViewModelProtocol?
    @Environment(\.router) private var router
    @Environment(\.appCoordinator) private var appCoordinator
    
    let flowToken: String
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            VStack {
                navBtnSection
                    .padding(.bottom, 10)
                
                titleSection
                    .padding(.bottom, 30)
                
                loginCredentialsSection
                    .padding(.bottom, 20)
                
                Spacer()
                
                TuppView()
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
        }
        .navigationBarBackButtonHidden()
    }
}

// MARK: - View sections
extension EmailLoginScreen {
    // Nav button section
    private var navBtnSection: some View {
        HStack {
            Button {
                appCoordinator?.auth.dismissScreen(on: router)
            } label: {
                Image(systemName: "arrow.backward")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.outline)
                    .frame(width: 25, height: 25)
            }
            
            Spacer()
            
            Button {
                appCoordinator?.auth.dismissEnvironment(on: router)
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.outline)
                    .frame(width: 20, height: 20)
            }
        }
    }
    
    // Title section
    private var titleSection: some View {
        VStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 5)
            
            Text("Welcome back")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Text("Continue with you login credentials.")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(.secondaryText)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    // Email/password login section/
    private var loginCredentialsSection: some View {
        VStack {
            Text("Email address")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField(
                "",
                text: .constant(vm?.email ?? ""),
                prompt: Text(verbatim: "name@example.com")
                    .fontWeight(.regular)
            )
            .disabled(true)
            .textFieldStyle(.plain)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.secondaryText)
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
            
            Text("Password")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SecureField(
                "",
                text: Binding(
                    get: { vm?.password ?? "" },
                    set: { vm?.password = $0 }
                ),
                prompt: Text(verbatim: "Type password")
                    .fontWeight(.regular)
            )
            .textFieldStyle(.plain)
            .autocapitalization(.none)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.secondaryText)
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
                    await vm?.loginWithEmailComplete(flowToken: flowToken)
                    appCoordinator?.auth.dismissEnvironment(on: router)
                }
            } label: {
                HStack {
                    Text("Login")
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
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.reversePrimaryText)
        )
    }
}

// MARK: - Previews
#Preview("Normal") {
    let mockUserDefaults = UserDefaults(suiteName: "au.com.matrixthoughts.TrackerParent.mock") ?? .standard
    
    let mockAuthViewModel = AuthViewModel(userDefaults: mockUserDefaults)
    mockAuthViewModel.email = "test@test.com"
    
    return RouterView { _ in
        EmailLoginScreen(flowToken: "")
            .environment(\.authViewModel, mockAuthViewModel)
            .environment(\.appCoordinator, AppCoordinator())
    }
}
