//
//  RegisterVerificationScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 08/04/2025.
//

import SwiftUI
import SwiftfulRouting

struct RegisterVerificationScreen: View {
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
                Image(systemName: "envelope.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                    .padding(.trailing, 8)
                
                TextField("Email for username to login", text: $registerViewModel.email)
                    .font(.subheadline)
                    .keyboardType(.emailAddress)
                    .clearButton($registerViewModel.email)
                
                Button {
                    Task {
                        await registerViewModel.requestVerificationCode()
                    }
                } label: {
                    Text(registerViewModel.resendCountDown > 0 ? "(\(registerViewModel.resendCountDown)) Retry" : "Send code")
                        .font(.subheadline)
                        .foregroundStyle(registerViewModel.resendCountDown > 0 ? .gray : .black)
                        .padding(8)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(registerViewModel.resendCountDown > 0 ? .gray : .black, lineWidth: 1)
                        }
                }
                .disabled(registerViewModel.resendCountDown > 0)
            }
            .padding(.leading, 10)
            .padding(.bottom, 15)
            
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20)
                    .padding(.trailing, 8)
                
                TextField("Verification code", text: $registerViewModel.verificationCode)
                    .font(.subheadline)
                    .keyboardType(.numberPad)
                    .clearButton($registerViewModel.verificationCode)
                
                Menu {
                    Text("Please go to your email to get the verification code.")
                        .font(.caption2)
                } label: {
                    Image(systemName: "questionmark.app.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18)
                        .foregroundStyle(.black)
                }
            }
            .padding(.leading, 10)
            .padding(.bottom, 80)
            
            // Verify btn
            Button {
                Task {
                    await registerViewModel.verifyEmail()
                }
            } label: {
                Text("Verify")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 40)
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
                
                registerViewModel.verificationCode = ""
                
                router.showScreen(.push) { router2 in
                    RegisterConfirmationScreen(router: router2, registerViewModel: registerViewModel)
                }
            case .failure:
                if let errMsg = registerViewModel.errMsg {
                    toastViewObserver.showToast(message: errMsg)
                }
            }
        })
        .onAppear {
            if registerViewModel.resendCountDown > 0 {
                registerViewModel.startCountDown()
            }
        }
        .onDisappear {
            registerViewModel.stopCountDown()
        }
        .navigationTitle("Registration 1/2")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarRole(.editor)   // Remove the back btn title
        .padding()
        .toastView(toastViewObserver: toastViewObserver)
    }
}

#Preview {
    RouterView { router in
        RegisterVerificationScreen(router: router)
    }
    .environment(ToastViewObserver())
}
