//
//  LoginWithFaceIdUseCase.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 21/03/2026.
//

import Foundation

@MainActor
protocol LoginWithFaceIdUseCaseProtocol {
    func execute() async throws -> AuthModel?
}

final class LoginWithFaceIdUseCase: LoginWithFaceIdUseCaseProtocol, Loggable {
    private let keyChainUtil: KeyChainUtilProtocol
    private let userDefaults: UserDefaults
    
    init(
        keyChainUtil: KeyChainUtilProtocol = KeyChainUtil.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.keyChainUtil = keyChainUtil
        self.userDefaults = userDefaults
    }

    func execute() async throws -> AuthModel? {
        let account = userDefaults.string(forKey: "username") ?? ""
        guard !account.isEmpty else {
            throw CommError.serverReturnedError("No cached username")
        }
        guard let savedAuthModel = try keyChainUtil.loadObject(account: account, type: AuthModel.self) else {
            throw CommError.serverReturnedError("No auth model in keychain")
        }

        return savedAuthModel
    }
}
