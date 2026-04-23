//
//  MockAuthViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 15/04/2026.
//

import Foundation

@MainActor
@Observable
final class MockAuthViewModel: AuthViewModelProtocol {
    var username: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var loginState: RequestStatus = RequestStatus()
    var emailEntryState: RequestStatus = RequestStatus()
    var emailFlowDestination: EmailFlowDestination = .none
    var errMsg: String?
    var role: AccountRole?
    var faceIdEnabled: Bool = false
    var showFaceIdAlert: Bool = false
    var hasPromptedEnableFaceId: Bool = false
    var autoTriggerGoogleSignIn: Bool = false
    var autoTriggerAppleSignIn: Bool = false
    
    var showSettingsAlert: Bool = false
    var showEnrolAlert: Bool = false
    
    var shouldKeepLoading: Bool
    var shouldReturnError: Bool
//    var shouldReturnEmptyData: Bool
    var shouldEmailFlowToRegister: Bool
    var shouldEmailFlowToLogin: Bool
    
    init(
        shouldKeepLoading: Bool = false,
        shouldReturnError: Bool = false,
        shouldEmailFlowToRegister: Bool = false,
        shouldEmailFlowToLogin: Bool = false
    ) {
        self.shouldKeepLoading = shouldKeepLoading
        self.shouldReturnError = shouldReturnError
        self.shouldEmailFlowToRegister = shouldEmailFlowToRegister
        self.shouldEmailFlowToLogin = shouldEmailFlowToLogin
    }
    
    func loginWithEmailStart() async {
        // Mock loading
        emailEntryState.state = .loading
        errMsg = nil
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        if !shouldKeepLoading {
            if shouldReturnError {
                // Mock error
                emailEntryState.state = .failure
                errMsg = "Mock sending email start request error occurred"
            } else if shouldEmailFlowToRegister {
                // Mock email flow to register
                emailEntryState.state = .success
                emailFlowDestination = .register(flowToken: mockEmailFlowStartModel1.flowToken ?? "")
            } else if shouldEmailFlowToLogin {
                // Mock email flow to login
                emailEntryState.state = .success
                emailFlowDestination = .login(flowToken: mockEmailFlowStartModel2.flowToken ?? "")
            }
        }
    }
    
    func loginWithEmailComplete(flowToken: String) async {
        // Mock loading
        loginState.state = .loading
        loginState.errMsg = nil
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        if !shouldKeepLoading {
            if shouldReturnError {
                // Mock error
                loginState.state = .failure
                errMsg = "Mock email login request error occurred"
            } else {
                // Mock email login success
                loginState.state = .success
            }
        }
    }
    
    func registerWithEmailComplete(flowToken: String) async {
        
    }
    
    func loginWithSSO(type: SSOType) async {
        
    }
    
    func loginWithFaceId() async {
        
    }
    
    func updateFaceIdStatus(faceIdEnabled: Bool, hasPrompted: Bool) {
        
    }
    
    func changeToLoading() async {
        // Mock loading
        loginState.state = .none
        emailEntryState.state = .none
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        loginState.state = .loading
        emailEntryState.state = .loading
    }
}
