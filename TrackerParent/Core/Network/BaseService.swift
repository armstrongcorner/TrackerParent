//
//  BaseService.swift
//  sidu
//
//  Created by Armstrong Liu on 06/03/2025.
//

import Foundation

protocol BaseServiceProtocol: Sendable {
    func getDefaultHeaders(for account: String?) throws -> [String: String]
}

extension BaseServiceProtocol {
    func getDefaultHeaders(for account: String? = nil) throws -> [String: String] {
        var headers: [String: String] = [:]
        
        // Put keychain cached token to header
        var theAccount: String?
        if account == nil {
            theAccount = UserDefaults.standard.string(forKey: "username") ?? ""
        } else {
            theAccount = account
        }
        
        if let bundleId = Bundle.main.bundleIdentifier,
           let theAccount,
           let savedAuthModel = try KeyChainUtil.shared.loadObject(service: bundleId, account: theAccount, type: AuthModel.self),
           let accessToken = savedAuthModel.accessToken
        {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        
        return headers
    }
}
