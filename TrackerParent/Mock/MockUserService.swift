//
//  MockUserService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 07/04/2025.
//

import Foundation

actor MockUserService: UserServiceProtocol {
    var userResponse: UserResponse?
    var userListResponse: UserListResponse?
    var shouldReturnError: Bool = false
    var commError: CommError?
    
    func setUserResponse(_ userResponse: UserResponse?) {
        self.userResponse = userResponse
    }
    
    func setUserListResponse(_ userListResponse: UserListResponse?) {
        self.userListResponse = userListResponse
    }

    func setShouldReturnError(_ shouldReturnError: Bool) {
        self.shouldReturnError = shouldReturnError
    }
    
    func setCommError(_ commError: CommError?) {
        self.commError = commError
    }
    
    func getUserInfo(username: String) async throws -> UserResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let userResponse = userResponse, !shouldReturnError {
            return userResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
    
    func getUserList() async throws -> UserListResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let userListResponse = userListResponse, !shouldReturnError {
            return userListResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
    
    func checkUserExists(username: String) async throws -> UserExistResponse? {
        //
        return nil
    }
    
    func sendVerificationEmail(username: String) async throws -> AuthResponse? {
        //
        return nil
    }
    
    func verifyEmail(username: String, code: String) async throws -> UserResponse? {
        //
        return nil
    }
    
    func completeRegister(username: String, password: String) async throws -> AuthResponse? {
        //
        return nil
    }
}
