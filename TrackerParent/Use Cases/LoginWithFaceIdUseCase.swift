//
//  LoginWithFaceIdUseCase.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 21/03/2026.
//

import Foundation
import OSLog

@MainActor
protocol LoginWithFaceIdUseCaseProtocol {
    func execute() async throws -> UserResponse?
}

final class LoginWithFaceIdUseCase: LoginWithFaceIdUseCaseProtocol {
    private let userService: UserServiceProtocol
    private let keyChainUtil: KeyChainUtilProtocol
    private let userDefaults: UserDefaults

    private let logger: Logger
    
    init(
        userService: UserServiceProtocol = UserService(),
        keyChainUtil: KeyChainUtilProtocol = KeyChainUtil.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.userService = userService
        self.keyChainUtil = keyChainUtil
        self.userDefaults = userDefaults
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        self.logger = Logger(subsystem: bundleId, category: String(describing: type(of: self)))
    }

    func execute() async throws -> UserResponse? {
        let account = userDefaults.string(forKey: "username") ?? ""
        if let savedAuthModel = try keyChainUtil.loadObject(account: account, type: AuthModel.self) {
            logger.debug("--- auth model in keychain: \(String(describing: savedAuthModel))")
            if let userResponse = try await userService.getUserInfo(username: account) {
                return userResponse
            }
            
            return nil
        } else {
            throw CommError.serverReturnedError("No auth model in keychain")
        }
    }
}
