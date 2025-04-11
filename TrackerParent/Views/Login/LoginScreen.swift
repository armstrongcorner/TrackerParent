//
//  LoginScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 13/03/2025.
//

import SwiftUI
import SwiftfulRouting

struct LoginScreen: View {
    @Environment(ToastViewObserver.self) var toastViewObserver
    
    @State private var authViewModel: AuthViewModelProtocol
    let router: AnyRouter
    
    init(
        router: AnyRouter,
        authViewModel: AuthViewModelProtocol = AuthViewModel()
    ) {
        self.router = router
        self.authViewModel = authViewModel
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // Username
            HStack {
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                    .padding(.trailing, 8)
                TextField("Username", text: $authViewModel.username)
                    .font(.title2)
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
                    .font(.title2)
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
            .padding(.bottom, 40)
            
            // Login with faceID
            Button {
                Task {
                    await authViewModel.loginWithFaceId()
                }
            } label: {
                Image(systemName: "faceid")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60)
            }
            .alert("Face ID disabled", isPresented: $authViewModel.showSettingsAlert) {
                Button("Cancel", role: .cancel) {
                    toastViewObserver.dismissLoading()
                }
                Button("Settings") {
                    toastViewObserver.dismissLoading()
                    
                    if let url = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please enable 'Face ID' in the app settings")
            }
            .alert("Face ID not enrolled", isPresented: $authViewModel.showEnrolAlert) {
                Button("OK", role: .cancel) {
                    toastViewObserver.dismissLoading()
                }
            } message: {
                Text("Please enrol a Face ID first")
            }
            
            Spacer()
            
            Button {
                router.showScreen(.push) { router2 in
                    RegisterVerificationScreen(router: router2)
                }
            } label: {
                Text("Create new account")
                    .padding()
            }
        }
        .onChange(of: authViewModel.loginState, { oldValue, newValue in
            switch newValue {
            case .none:
                toastViewObserver.dismissLoading()
            case .loading:
                toastViewObserver.showLoading()
            case .success:
                toastViewObserver.dismissLoading()
                authViewModel.username = ""
                authViewModel.password = ""
                
                router.showScreen(.push) { router2 in
                    if authViewModel.role == "User" {
                        TrackListScreen(router: router2)
                    } else if authViewModel.role == "Administrator" {
                        UserListScreen(router: router2)
                    }
                }
            case .failure:
                if let errMsg = authViewModel.errMsg {
                    toastViewObserver.showToast(message: errMsg)
                }
            }
        })
        .padding()
        .toastView(toastViewObserver: toastViewObserver)
    }
}

#Preview {
    RouterView { router in
        LoginScreen(router: router)
    }
    .environment(ToastViewObserver())
}
