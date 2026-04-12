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
    @Environment(\.appCoordinator) private var appCoordinator
    @Environment(ToastViewObserver.self) private var toastViewObserver
    @Environment(SessionManager.self) private var sessionManager
    
    @State private var vm: AuthViewModelProtocol
    
    init(vm: AuthViewModelProtocol) {
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
        .customAlert(isPresented: $vm.showFaceIdAlert) {
            faceIdAlertView
                .padding()
        }
        .task {
            if vm.faceIdEnabled {
                await vm.loginWithFaceId()
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
                sessionManager.reloadFromStorage()
                if vm.hasPromptedEnableFaceId {
                    appCoordinator?.auth.show(.postLogin(role: vm.role ?? .user), on: router)
                } else {
                    vm.showFaceIdAlert = true
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

    // Apple sign in button
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
            .frame(maxWidth: .infinity)
            .outlineRoundedButtonStyle()
        }
        .withPressableButtonStyle()
    }
    
    // Google sign in button
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
            .frame(maxWidth: .infinity)
            .outlineRoundedButtonStyle()
        }
        .withPressableButtonStyle()
    }
    
    // Email sign in button
    private var emailSignInBtn: some View {
        Button {
            navigateToEmailSignIn()
        } label: {
            HStack {
                Image(systemName: "lock.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23, height: 23)
                
                Text("Login or Sign Up")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .outlineRoundedButtonStyle()
            
        }
        .withPressableButtonStyle()
    }
}

// MARK: - Other views
extension LoginScreen {
    // FaceId alert
    private var faceIdAlertView: some View {
        VStack(spacing: 20) {
            Image(systemName: "faceid")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundStyle(.mainTheme)
                .padding()
            
            Text("Enable FaceID")
                .font(.title2)
                .bold()
                .foregroundColor(.primaryText)

            Text("Use FaceID for a faster and more secure way to log in next time.")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            
            Button {
                vm.showFaceIdAlert = false
                vm.updateFaceIdStatus(faceIdEnabled: true, hasPrompted: true)
                appCoordinator?.auth.show(.postLogin(role: vm.role ?? .user), on: router)
            } label: {
                Text("Enable")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 30)
                    .outlineRoundedButtonStyle(
                        buttonBackground: AnyShapeStyle(
                            LinearGradient(
                                colors: [.mainTheme, .mainTheme.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing)
                        ),
                        buttonTextColor: .white,
                        outlineWidth: 0
                    )
                    .shadow(color: .mainTheme, radius: 1, x: 0, y: 2)
            }
            .withPressableButtonStyle()
            
            Button {
                vm.showFaceIdAlert = false
                vm.updateFaceIdStatus(faceIdEnabled: false, hasPrompted: true)
                appCoordinator?.auth.show(.postLogin(role: vm.role ?? .user), on: router)
            } label: {
                Text("Not Now")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 30)
                    .outlineRoundedButtonStyle()
            }
            .withPressableButtonStyle()
        }
        .padding()
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.secondaryBackground)
        )
    }
}

// MARK: - Navigations
extension LoginScreen {
    private func navigateToEmailSignIn() {
        let config = ResizableSheetConfig(
            detents: [.fraction(0.8), .large],
            dragIndicator: .automatic,
            backgroundInteraction: .disabled
        )
        appCoordinator?.auth.show(
            .emailEntry(vm: vm),
            on: router,
            sheetConfig: config
        ) { [weak vm] in
            guard let vm else { return }

            Task {
                if vm.autoTriggerGoogleSignIn {
                    vm.autoTriggerGoogleSignIn.toggle()
                    await vm.loginWithSSO(type: .google)
                } else if vm.autoTriggerAppleSignIn {
                    vm.autoTriggerAppleSignIn.toggle()
                    await vm.loginWithSSO(type: .apple)
                }
            }
        }
    }
}

// MARK: - Previews
#Preview("Normal") {
    let mockUserDefaults = UserDefaults(suiteName: "au.com.matrixthoughts.TrackerParent.mock") ?? .standard
    
    let mockAuthViewModel = AuthViewModel(userDefaults: mockUserDefaults)
    
    return RouterView { _ in
        LoginScreen(vm: mockAuthViewModel)
    }
    .environment(SessionManager())
    .environment(ToastViewObserver())
}

#Preview("Pop FaceID alert") {
    let mockUserDefaults = UserDefaults(suiteName: "au.com.matrixthoughts.TrackerParent.mock1") ?? .standard
    mockUserDefaults.set("a.b@test.com", forKey: "username")
    mockUserDefaults.set(false, forKey: "a.b@test.com_hasPromptedEnableFaceId")
    
    let mockAuthViewModel = AuthViewModel(userDefaults: mockUserDefaults)
    mockAuthViewModel.showFaceIdAlert = true
    
    return RouterView { _ in
        LoginScreen(vm: mockAuthViewModel)
    }
    .environment(SessionManager())
    .environment(ToastViewObserver())
}

#Preview("Clean up UserDefaults") {
    Text("")
        .onAppear {
            let mockUserDefaults = UserDefaults(suiteName: "au.com.matrixthoughts.TrackerParent.mock") ?? .standard
            mockUserDefaults.removePersistentDomain(forName: "au.com.matrixthoughts.TrackerParent.mock")
        }
}
