//
//  LoginFirebaseUseCase.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 21/03/2026.
//

import Foundation
import OSLog
import MTAuthHelper
import FirebaseAuth

@MainActor
protocol LoginFirebaseUseCaseProtocol {
    func execute(type: SSOType) async throws -> AuthResponse?
}

final class LoginFirebaseUseCase: LoginFirebaseUseCaseProtocol {
    private let loginService: LoginServiceProtocol
    private let keyChainUtil: KeyChainUtilProtocol

    private let logger: Logger

    init(
        loginService: LoginServiceProtocol = LoginService(),
        keyChainUtil: KeyChainUtilProtocol = KeyChainUtil.shared
    ) {
        self.loginService = loginService
        self.keyChainUtil = keyChainUtil
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        self.logger = Logger(subsystem: bundleId, category: String(describing: type(of: self)))
    }
    
    func execute(type: SSOType) async throws -> AuthResponse? {
        var authDataResult: AuthDataResult?
        switch type {
        case .apple:
            authDataResult = try await MTAuthHelper.shared.handleAppleSignIn()
        case .google:
            authDataResult = try await MTAuthHelper.shared.handleGoogleSignIn()
        }
        
        guard let authDataResult else {
            logger.debug("--- Empty Firebase auth data result ---")
            throw MTAuthError.unknown
        }
        
        let idToken = try await MTAuthHelper.shared.getIdToken(from: authDataResult.user)
        if let authResponse = try await loginService.loginWithFirebase(
            idToken: idToken,
            deviceId: StringUtil.shared.getDeviceId()
        ) {
            if authResponse.isSuccess, let authModel = authResponse.value {
                logger.debug("--- auth model: \(String(describing: authModel))")
                
                // Save the username to UserDefault
//                userDefaults.set(username, forKey: "username")
                let email = ""
                
                // Save the auth model to Keychain
                try keyChainUtil.saveObject(account: email, object: authModel)
            }
            
            return authResponse
        }
        
        return nil
    }
}
