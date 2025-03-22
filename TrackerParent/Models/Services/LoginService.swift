//
//  LoginService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 15/03/2025.
//

import Foundation

struct LoginRequestBody: Encodable {
    let username: String
    let password: String
}

protocol LoginServiceProtocol: Sendable {
    func login(username: String, password: String) async throws -> AuthResponse?
}

actor LoginService: LoginServiceProtocol, BaseServiceProtocol {
    private let apiClient: ApiClientProtocol
    
    init(apiClient: ApiClientProtocol = ApiClient()) {
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
