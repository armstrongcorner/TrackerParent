//
//  LoginService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 15/03/2025.
//

import Foundation
import MTNetworkManager

protocol LoginServiceProtocol: Sendable {
    func loginWithEmailStart(email: String,deviceId: String?) async throws -> EmailFlowStartResponse?
    func loginWithEmailComplete(flowToken: String, idToken: String, deviceId: String?) async throws -> AuthResponse?
    func loginWithFirebase(idToken: String, deviceId: String?) async throws -> AuthResponse?
}

actor LoginService: LoginServiceProtocol, BaseServiceProtocol {
    private let apiClient: MTApiClientProtocol
    
    init(apiClient: MTApiClientProtocol = MTApiClient()) {
        self.apiClient = apiClient
    }
    
    func loginWithEmailStart(email: String,deviceId: String?) async throws -> EmailFlowStartResponse? {
        struct EmailStartRequestBody: Codable {
            let email: String
            let deviceId: String
        }

        let requestBody = EmailStartRequestBody(email: email, deviceId: deviceId ?? "")
        
        let response = try await apiClient.post(
            urlString: Endpoint.emailStart.urlString,
            body: requestBody,
            responseType: EmailFlowStartResponse.self
        )
        
        return response
    }
    
    func loginWithEmailComplete(flowToken: String, idToken: String, deviceId: String?) async throws -> AuthResponse? {
        struct EmailCompleteRequestBody: Codable {
            let flowToken: String
            let firebaseIdToken: String
            let deviceId: String
        }

        let requestBody = EmailCompleteRequestBody(flowToken: flowToken, firebaseIdToken: idToken, deviceId: deviceId ?? "")
        
        let response = try await apiClient.post(
            urlString: Endpoint.emailComplete.urlString,
            body: requestBody,
            responseType: AuthResponse.self
        )
        
        return response
    }
    
    func loginWithFirebase(idToken: String, deviceId: String?) async throws -> AuthResponse? {
        struct FirebaseLoginRequestBody: Codable {
            let firebaseIdToken: String
            let deviceId: String
        }

        let requestBody = FirebaseLoginRequestBody(firebaseIdToken: idToken, deviceId: deviceId ?? "")
        
        let response = try await apiClient.post(
            urlString: Endpoint.firebaseLogin.urlString,
            body: requestBody,
            responseType: AuthResponse.self
        )
        
        return response
    }
}
