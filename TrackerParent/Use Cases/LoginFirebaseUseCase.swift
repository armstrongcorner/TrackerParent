//
//  LoginFirebaseUseCase.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 21/03/2026.
//

import Foundation
import MTAuthHelper
import FirebaseAuth

@MainActor
protocol LoginFirebaseUseCaseProtocol {
    func execute(type: SSOType) async throws -> AuthResponse?
}

final class LoginFirebaseUseCase: LoginFirebaseUseCaseProtocol, Loggable {
    private let loginService: LoginServiceProtocol
    private let keyChainUtil: KeyChainUtilProtocol
    private let userDefaults: UserDefaults

    init(
        loginService: LoginServiceProtocol = LoginService(),
        keyChainUtil: KeyChainUtilProtocol = KeyChainUtil.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.loginService = loginService
        self.keyChainUtil = keyChainUtil
        self.userDefaults = userDefaults
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
            if authResponse.isSuccess, let authModel = authResponse.value, let email = authModel.user?.email {
                logger.debug("--- auth model: \(String(describing: authModel))")
                
                // Save the username to UserDefault
                userDefaults.set(email, forKey: "username")
                
                // Save the auth model to Keychain
                try keyChainUtil.saveObject(account: email, object: authModel)
            }
            
            return authResponse
        }
        
        return nil
    }
}
