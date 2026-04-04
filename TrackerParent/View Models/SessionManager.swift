//
//  SessionManager.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 11/08/2025.
//

import Foundation

@MainActor
@Observable
final class SessionManager {
    private(set) var username: String?
    private(set) var authModel: AuthModel?
    private(set) var role: AccountRole?

    @ObservationIgnored
    private let keyChainUtil: KeyChainUtilProtocol
    @ObservationIgnored
    private let userDefaults: UserDefaults

    var currentUser: UserModel? {
        authModel?.user
    }

    var currentWatchRelationshipId: Int? {
        authModel?.user?.currentWatchRelationshipId
    }

    init(
        keyChainUtil: KeyChainUtilProtocol = KeyChainUtil.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.keyChainUtil = keyChainUtil
        self.userDefaults = userDefaults
        reloadFromStorage()
    }

    func reloadFromStorage() {
        let account = userDefaults.string(forKey: "username")
        username = account

        guard let account, !account.isEmpty else {
            clearSession()
            return
        }

        do {
            let authModel = try keyChainUtil.loadObject(account: account, type: AuthModel.self)
            self.authModel = authModel
            role = AccountRole(rawValue: authModel?.user?.role ?? "")
        } catch {
            clearSession()
        }
    }

    func updateAuthModel(_ authModel: AuthModel?, for username: String?) {
        self.username = username
        self.authModel = authModel
        role = AccountRole(rawValue: authModel?.user?.role ?? "")
    }

    func updateCurrentWatchRelationshipId(_ watchRelationshipId: Int?) {
        guard
            let authModel,
            let username,
            !username.isEmpty
        else {
            return
        }

        var user = authModel.user
        user?.currentWatchRelationshipId = watchRelationshipId

        let updatedAuthModel = AuthModel(
            accessToken: authModel.accessToken,
            accessTokenExpiresAt: authModel.accessTokenExpiresAt,
            expiresIn: authModel.expiresIn,
            refreshToken: authModel.refreshToken,
            user: user
        )

        self.authModel = updatedAuthModel
        role = AccountRole(rawValue: updatedAuthModel.user?.role ?? "")

        do {
            try keyChainUtil.saveObject(account: username, object: updatedAuthModel)
        } catch {
            return
        }
    }

    func clearSession() {
        username = nil
        authModel = nil
        role = nil
    }
}
