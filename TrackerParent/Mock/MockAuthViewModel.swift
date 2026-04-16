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
    
    init(
        shouldKeepLoading: Bool = false,
        shouldReturnError: Bool = false,
        shouldReturnEmptyData: Bool = false
    ) {
        self.shouldKeepLoading = shouldKeepLoading
        self.shouldReturnError = shouldReturnError
        self.shouldReturnEmptyData = shouldReturnEmptyData
    }
    
    func loginWithEmailStart() async {
        
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
        
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        loginState = .loading
    }
}
