//
//  UserService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/18.
//

import Foundation

protocol UserServiceProtocol: Sendable {
    func getUserInfo(username: String) async throws -> UserResponse?
}

actor UserService: UserServiceProtocol, BaseServiceProtocol {
    private let apiClient: ApiClientProtocol
    
    init(apiClient: ApiClientProtocol = ApiClient()) {
        self.apiClient = apiClient
    }

    func getUserInfo(username: String) async throws -> UserResponse? {
        let defaultHeaders = try getDefaultHeaders()
        
        let response = try await apiClient.get(
            urlString: Endpoint.userInfo(username).urlString,
            headers: defaultHeaders,
            responseType: UserResponse.self
        )
        
        return response
    }
}
