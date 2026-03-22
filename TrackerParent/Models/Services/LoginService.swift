//
//  LoginService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 15/03/2025.
//

import Foundation
import MTNetworkManager

struct EmailLoginRequestBody: Codable {
    let username: String
    let password: String
}

struct FirebaseLoginRequestBody: Codable {
    let firebaseIdToken: String
}

protocol LoginServiceProtocol: Sendable {
    func login(username: String, password: String) async throws -> AuthResponse?
    func loginWithFirebase(idToken: String) async throws -> AuthResponse?
}

actor LoginService: LoginServiceProtocol, BaseServiceProtocol {
    private let apiClient: MTApiClientProtocol
    
    init(apiClient: MTApiClientProtocol = MTApiClient()) {
        self.apiClient = apiClient
    }
    
    func login(username: String, password: String) async throws -> AuthResponse? {
        let requestBody = EmailLoginRequestBody(username: username, password: password)
        
        let response = try await apiClient.post(
            urlString: Endpoint.login.urlString,
            body: requestBody,
            responseType: AuthResponse.self
        )
        
        return response
    }
    
    func loginWithFirebase(idToken: String) async throws -> AuthResponse? {
        let requestBody = FirebaseLoginRequestBody(firebaseIdToken: idToken)
        
        let response = try await apiClient.post(
            urlString: Endpoint.firebaseLogin.urlString,
            body: requestBody,
            responseType: AuthResponse.self
        )
        
        return response
    }
}
