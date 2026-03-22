//
//  LoginUseCase.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 21/03/2026.
//

import Foundation
import OSLog

@MainActor
protocol LoginUseCaseProtocol {
    func execute(username: String, password: String) async throws -> AuthResponse?
}

final class LoginUseCase: LoginUseCaseProtocol {
    private let loginService: LoginServiceProtocol
    private let keyChainUtil: KeyChainUtilProtocol
    private let userDefaults: UserDefaults
    
    private let logger: Logger
    
    init(
        loginService: LoginServiceProtocol = LoginService(),
        keyChainUtil: KeyChainUtilProtocol = KeyChainUtil.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.loginService = loginService
        self.keyChainUtil = keyChainUtil
        self.userDefaults = userDefaults
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        self.logger = Logger(subsystem: bundleId, category: String(describing: type(of: self)))
    }
    
    func execute(username: String, password: String) async throws -> AuthResponse? {
        if let authResponse = try await loginService.login(username: username, password: password) {
            if authResponse.isSuccess, let authModel = authResponse.value {
                logger.debug("--- auth model: \(String(describing: authModel))")
                
                // Save the username to UserDefault
                userDefaults.set(username, forKey: "username")
                
                // Save the auth model to Keychain
                try keyChainUtil.saveObject(account: username, object: authModel)
            }
            
            return authResponse
        }
        
        return nil
    }
}
