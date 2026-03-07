//
//  LoginService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 15/03/2025.
//

import Foundation
import MTNetworkManager

struct LoginRequestBody: Codable {
    let username: String
    let password: String
}

protocol LoginServiceProtocol: Sendable {
    func login(username: String, password: String) async throws -> AuthResponse?
}

actor LoginService: LoginServiceProtocol, BaseServiceProtocol {
    private let apiClient: MTApiClientProtocol
    
    init(apiClient: MTApiClientProtocol = MTApiClient()) {
        self.apiClient = apiClient
    }
    
    func login(username: String, password: String) async throws -> AuthResponse? {
        let requestBody = LoginRequestBody(username: username, password: password)
        
        let response = try await apiClient.post(
            urlString: Endpoint.login.urlString,
            body: requestBody,
            responseType: AuthResponse.self
        )
        
        return response
    }
}
