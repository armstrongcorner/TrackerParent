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
    var loginState: CommReqState = .none
    var emailEntryState: CommReqState = .none
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
    var shouldReturnEmptyData: Bool
    var shouldEmailFlowToRegister: Bool
    var shouldEmailFlowToLogin: Bool
    
    init(
        shouldKeepLoading: Bool = false,
        shouldReturnError: Bool = false,
        shouldReturnEmptyData: Bool = false,
        shouldEmailFlowToRegister: Bool = false,
        shouldEmailFlowToLogin: Bool = false
    ) {
        self.shouldKeepLoading = shouldKeepLoading
        self.shouldReturnError = shouldReturnError
        self.shouldReturnEmptyData = shouldReturnEmptyData
        self.shouldEmailFlowToRegister = shouldEmailFlowToRegister
        self.shouldEmailFlowToLogin = shouldEmailFlowToLogin
    }
    
    func loginWithEmailStart() async {
        // Mock loading
        emailEntryState = .loading
        errMsg = nil
        
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        if !shouldKeepLoading {
            if shouldReturnError {
                // Mock error
                emailEntryState = .failure
                errMsg = "Mock sending email start request error occurred"
            } else if shouldEmailFlowToRegister {
                // Mock email flow to register
                emailEntryState = .success
                emailFlowDestination = .register(flowToken: mockEmailFlowStartModel1.flowToken ?? "")
            } else if shouldEmailFlowToLogin {
                // Mock email flow to login
                emailEntryState = .success
                emailFlowDestination = .login(flowToken: mockEmailFlowStartModel2.flowToken ?? "")
            }
        }
    }
    
    func loginWithEmailComplete(flowToken: String) async {
        
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
        loginState = .none
        emailEntryState = .none
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        loginState = .loading
        emailEntryState = .loading
    }
}
