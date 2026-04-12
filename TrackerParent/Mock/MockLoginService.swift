//
//  MockLoginService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 16/03/2025.
//

import Foundation

actor MockLoginService: LoginServiceProtocol {
    var emailFlowStartResponse: EmailFlowStartResponse?
    var authResponse: AuthResponse?
    var shouldReturnError: Bool = false
    var loginError: LoginError?
    var commError: CommError?
    
    func setEmailFlowStartResponse(_ emailFlowStartResponse: EmailFlowStartResponse?) {
        self.emailFlowStartResponse = emailFlowStartResponse
    }

    func setAuthResponse(_ authResponse: AuthResponse?) {
        self.authResponse = authResponse
    }
    
    func setShouldReturnError(_ shouldReturnError: Bool) {
        self.shouldReturnError = shouldReturnError
    }
    
    func setLoginError(_ loginError: LoginError?) {
        self.loginError = loginError
    }
    
    func setCommError(_ commError: CommError?) {
        self.commError = commError
    }
    
    func loginWithEmailStart(email: String, deviceId: String?) async throws -> EmailFlowStartResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let emailFlowStartResponse = emailFlowStartResponse, !shouldReturnError {
            return emailFlowStartResponse
        } else if let loginError = loginError {
            throw loginError
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
    
    func loginWithEmailComplete(flowToken: String, idToken: String, deviceId: String?) async throws -> AuthResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let authResponse = authResponse, !shouldReturnError {
            return authResponse
        } else if let loginError = loginError {
            throw loginError
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
    
    func loginWithFirebase(idToken: String, deviceId: String?) async throws -> AuthResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let authResponse = authResponse, !shouldReturnError {
            return authResponse
        } else if let loginError = loginError {
            throw loginError
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
}
