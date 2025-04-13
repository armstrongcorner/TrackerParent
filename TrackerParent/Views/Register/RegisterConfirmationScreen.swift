//
//  RegisterConfirmationScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 08/04/2025.
//

import SwiftUI
import SwiftfulRouting

struct RegisterConfirmationScreen: View {
    @Environment(ToastViewObserver.self) var toastViewObserver
    
    @State private var registerViewModel: RegisterViewModelProtocol
    let router: AnyRouter
    
    init(
        router: AnyRouter,
        registerViewModel: RegisterViewModelProtocol = RegisterViewModel()
    ) {
        self.router = router
        self.registerViewModel = registerViewModel
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "lock.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                    .padding(.trailing, 8)
                
                SecureField("Password", text: $registerViewModel.password)
                    .font(.subheadline)
                    .clearButton($registerViewModel.email)
            }
            .padding(.leading, 10)
            .padding(.bottom, 15)
            
            HStack {
                Image(systemName: "lock.shield")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 25)
                    .padding(.trailing, 8)
                
                SecureField("Cofirm password", text: $registerViewModel.confirmPassword)
                    .font(.subheadline)
                    .clearButton($registerViewModel.verificationCode)
            }
            .padding(.leading, 10)
            .padding(.bottom, 80)
            
            // Complete btn
            Button {
                Task {
                    await registerViewModel.register()
                }
            } label: {
                Text("Complete Registration")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 230, height: 40)
                    .background(.primary)
                    .cornerRadius(10)
            }
        }
        .onChange(of: registerViewModel.registerState, { oldValue, newValue in
            switch newValue {
            case .none:
                toastViewObserver.dismissLoading()
            case .loading:
                toastViewObserver.showLoading()
            case .success:
                toastViewObserver.dismissLoading()
                
                router.showScreen(.push) { router2 in
                    TrackListScreen(router: router2)
                }
            case .failure:
                if let errMsg = registerViewModel.errMsg {
                    toastViewObserver.showToast(message: errMsg)
                }
            }
        })
        .navigationTitle("Registration 2/2")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)   // Remove the back btn title
        .padding()
        .toastView(toastViewObserver: toastViewObserver)
    }
}

#Preview("completion failed") {
    let mockRegisterViewModel = MockRegisterViewModel()
    mockRegisterViewModel.shouldReturnError = true
    
    return RouterView { router in
        RegisterConfirmationScreen(router: router, registerViewModel: mockRegisterViewModel)
    }
    .environment(ToastViewObserver())
}

#Preview("completion success") {
    let mockRegisterViewModel = MockRegisterViewModel()
    
    return RouterView { router in
        RegisterConfirmationScreen(router: router, registerViewModel: mockRegisterViewModel)
    }
    .environment(ToastViewObserver())
}
