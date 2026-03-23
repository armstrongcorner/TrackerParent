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
    let deviceId: String
}

struct FirebaseLoginRequestBody: Codable {
    let firebaseIdToken: String
    let deviceId: String
}

protocol LoginServiceProtocol: Sendable {
    func login(username: String, password: String, deviceId: String?) async throws -> AuthResponse?
    func loginWithFirebase(idToken: String, deviceId: String?) async throws -> AuthResponse?
}

actor LoginService: LoginServiceProtocol, BaseServiceProtocol {
    private let apiClient: MTApiClientProtocol
    
    init(apiClient: MTApiClientProtocol = MTApiClient()) {
        self.apiClient = apiClient
    }
    
    func login(username: String, password: String, deviceId: String?) async throws -> AuthResponse? {
        let requestBody = EmailLoginRequestBody(username: username, password: password, deviceId: deviceId ?? "")
        
        let response = try await apiClient.post(
            urlString: Endpoint.login.urlString,
            body: requestBody,
            responseType: AuthResponse.self
        )
        
        return response
    }
    
    func loginWithFirebase(idToken: String, deviceId: String?) async throws -> AuthResponse? {
        let requestBody = FirebaseLoginRequestBody(firebaseIdToken: idToken, deviceId: deviceId ?? "")
        
        let response = try await apiClient.post(
            urlString: Endpoint.firebaseLogin.urlString,
            body: requestBody,
            responseType: AuthResponse.self
        )
        
        return response
    }
}
