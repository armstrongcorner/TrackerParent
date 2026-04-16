//
//  LoginWithEmailUseCase.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 14/04/2026.
//

import Foundation
import MTAuthHelper

@MainActor
protocol LoginWithEmailUseCaseProtocol {
    func execute(email: String, password: String, flowToken: String) async throws -> AuthResponse?
}

final class LoginWithEmailUseCase: LoginWithEmailUseCaseProtocol, Loggable {
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
    
    func execute(email: String, password: String, flowToken: String) async throws -> AuthResponse? {
        let authDataResult = try await MTAuthHelper.shared.signIn(withEmail: email, password: password)
        let idToken = try await MTAuthHelper.shared.getIdToken(from: authDataResult.user)

        if let authResponse = try await loginService.loginWithEmailComplete(
            flowToken: flowToken,
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
