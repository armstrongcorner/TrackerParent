//
//  BaseService.swift
//  sidu
//
//  Created by Armstrong Liu on 06/03/2025.
//

import Foundation

protocol BaseServiceProtocol: Sendable {
    func getDefaultHeaders() throws -> [String: String]
}

extension BaseServiceProtocol {
    func getDefaultHeaders() throws -> [String: String] {
        var headers: [String: String] = [:]
        
        // Put keychain cached token to header
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        let account = UserDefaults.standard.string(forKey: "username") ?? ""
        if let savedAuthModel = try KeyChainUtil.shared.loadObject(service: bundleId, account: account, type: AuthModel.self) {
            headers["Authorization"] = "Bearer \(savedAuthModel.token)"
        }
        
        return headers
    }
}
