//
//  LoginAfterSSOUseCase.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 21/03/2026.
//

import Foundation

@MainActor
protocol LoginAfterSSOUseCaseProtocol {
    func execute(idToken: String) async throws -> AuthResponse?
}

final class LoginAfterSSOUseCase: LoginAfterSSOUseCaseProtocol, Loggable {
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
    
    func execute(idToken: String) async throws -> AuthResponse? {
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
