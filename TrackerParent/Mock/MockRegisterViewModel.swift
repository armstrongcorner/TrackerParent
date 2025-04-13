//
//  MockRegisterViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 09/04/2025.
//

import Foundation

@MainActor
@Observable
final class MockRegisterViewModel: RegisterViewModelProtocol {
    var email: String = ""
    var verificationCode: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var registerState: CommReqState = .none
    var errMsg: String? = nil
    
    var resendCountDown = 0
    private var countDownTimer: Timer?
    
    var shouldReturnUserUnavailable: Bool = false
    var shouldReturnVerificationCodeNotMatch: Bool = false
    var shouldReturnError: Bool = false
    
    func startCountDown() {
        countDownTimer?.invalidate()
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.resendCountDown -= 1
                if self.resendCountDown == 0 {
                    self.countDownTimer?.invalidate()
                }
            }
        }
    }
    
    func stopCountDown() {
        countDownTimer?.invalidate()
        countDownTimer = nil
    }
    
    func requestVerificationCode() async {
        registerState = .none
        errMsg = nil

        // Validate email cannot be empty
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .failure
                self.errMsg = RegisterError.emptyEmail.errorDescription
            }
            return
        }
        
        // Validate email format
        guard StringUtil.shared.isValidEmail(email) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .failure
                self.errMsg = RegisterError.invalidEmail.errorDescription
            }
            return
        }

        if shouldReturnUserUnavailable {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .failure
                self.errMsg = "User unavailable"
            }
        } else {
            resendCountDown = RESEND_VERI_CODE_COUNTDOWN_IN_SEC
            startCountDown()
            
            if shouldReturnError {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.registerState = .failure
                    self.errMsg = "Sending verification email failed"
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.registerState = .none
                    self.errMsg = nil
                }
            }
        }
    }
    
    func verifyEmail() async {
        registerState = .none
        errMsg = nil

        // Validate email cannot be empty
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .failure
                self.errMsg = RegisterError.emptyEmail.errorDescription
            }
            return
        }
        
        // Validate email format
        guard StringUtil.shared.isValidEmail(email) else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .failure
                self.errMsg = RegisterError.invalidEmail.errorDescription
            }
            return
        }

        // Validate verification code cannot be empty
        guard !verificationCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .failure
                self.errMsg = RegisterError.emptyVerificationCode.errorDescription
            }
            return
        }
        
        registerState = .loading
        errMsg = nil
        
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if shouldReturnVerificationCodeNotMatch {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .failure
                self.errMsg = "Verification code does not match."
            }
        } else if shouldReturnError {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .failure
                self.errMsg = "Verifying procedure failed"
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .success
                self.errMsg = nil
            }
        }
    }
    
    func register() async {
        registerState = .none
        errMsg = nil

        // Validate password cannot be empty
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .failure
                self.errMsg = RegisterError.emptyPassword.errorDescription
            }
            return
        }
        
        // Validate confirm password cannot be empty
        guard !confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .failure
                self.errMsg = RegisterError.emptyConfirmPassword.errorDescription
            }
            return
        }
        
        // Validate password should be matched
        guard password == confirmPassword else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .failure
                self.errMsg = RegisterError.passwordNotMatch.errorDescription
            }
            return
        }
        
        registerState = .loading
        errMsg = nil
        
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if shouldReturnError {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .failure
                self.errMsg = "Completing registration failed"
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.registerState = .success
                self.errMsg = nil
            }
        }
    }
}
