//
//  UserService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/18.
//

import Foundation

struct SendVerificationEmailBody: Encodable {
    let username: String
    let role: String
    let language: String
    let email: String
    let tokenDurationInMin: Int
    let isActive: Bool
}

struct CompleteRegisterBody: Encodable {
    let username: String
    let password: String
    let activateUser: Bool
}

struct UpdateUserInfoBody: Encodable {
    let userName: String?
    let photo: String?
    let role: String?
    let mobile: String?
    let email: String?
    let serviceLevel: Int?
    let tokenDurationInMin: Int?
    let isActive: Bool?
}

protocol UserServiceProtocol: Sendable {
    func getUserInfo(username: String) async throws -> UserResponse?
    func getUserList() async throws -> UserListResponse?
    func updateUserInfo(newUserModel: UserModel) async throws -> UserResponse?
    func checkUserExists(username: String) async throws -> UserExistResponse?
    func sendVerificationEmail(username: String) async throws -> AuthResponse?
    func verifyEmail(username: String, code: String) async throws -> UserResponse?
    func completeRegister(username: String, password: String) async throws -> AuthResponse?
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
    
    func getUserList() async throws -> UserListResponse? {
        let defaultHeaders = try getDefaultHeaders()
        
        let response = try await apiClient.get(
            urlString: Endpoint.allUsers.urlString,
            headers: defaultHeaders,
            responseType: UserListResponse.self
        )
        
        return response
    }
    
    func updateUserInfo(newUserModel: UserModel) async throws -> UserResponse? {
        let defaultHeaders = try getDefaultHeaders()
        let requestBody = UpdateUserInfoBody(
            userName: newUserModel.userName,
            photo: newUserModel.photo,
            role: newUserModel.role,
            mobile: newUserModel.mobile,
            email: newUserModel.email,
            serviceLevel: newUserModel.serviceLevel,
            tokenDurationInMin: newUserModel.tokenDurationInMin,
            isActive: newUserModel.isActive
        )
        
        let response = try await apiClient.post(
            urlString: Endpoint.updateUser.urlString,
            headers: defaultHeaders,
            body: requestBody,
            responseType: UserResponse.self
        )
        
        return response
    }
    
    func checkUserExists(username: String) async throws -> UserExistResponse? {
        let defaultHeaders = try getDefaultHeaders()
        
        let response = try await apiClient.get(
            urlString: Endpoint.userExists(username).urlString,
            headers: defaultHeaders,
            responseType: UserExistResponse.self
        )
        
        return response
    }
    
    func sendVerificationEmail(username: String) async throws -> AuthResponse? {
        let defaultHeaders = try getDefaultHeaders(for: username)
        let requestBody = SendVerificationEmailBody(
            username: username,
            role: "User",
            language: "English",
            email: username,
            tokenDurationInMin: USER_DEFAULT_TOKEN_DURATION_IN_MIN,
            isActive: false
        )
        
        let response = try await apiClient.post(
            urlString: Endpoint.sendVerificationEmail.urlString,
            headers: defaultHeaders,
            body: requestBody,
            responseType: AuthResponse.self
        )
        
        return response
    }
    
    func verifyEmail(username: String, code: String) async throws -> UserResponse? {
        let defaultHeaders = try getDefaultHeaders(for: username)
        let requestBody = [
            "authenticationCode": code
        ]
        
        let response = try await apiClient.post(
            urlString: Endpoint.verifyEmail.urlString,
            headers: defaultHeaders,
            body: requestBody,
            responseType: UserResponse.self
        )
        
        return response
    }
    
    func completeRegister(username: String, password: String) async throws -> AuthResponse? {
        let defaultHeaders = try getDefaultHeaders(for: username)
        let requestBody = CompleteRegisterBody(
            username: username,
            password: password,
            activateUser: true
        )
        
        let response = try await apiClient.post(
            urlString: Endpoint.completeRegister.urlString,
            headers: defaultHeaders,
            body: requestBody,
            responseType: AuthResponse.self
        )
        
        return response
    }
}
