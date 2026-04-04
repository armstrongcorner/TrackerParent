//
//  MockUserService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 07/04/2025.
//

import Foundation

actor MockUserService: UserServiceProtocol {
    var invitationListResponse: InvitationListResponse?
    var invitationResponse: InvitationResponse?
    var watchRelationshipListResponse: WatchRelationshipListResponse?
    var setCurrentWatchResponse: EmptyPayloadResponse?
    
    var userResponse: UserResponse?
    var userListResponse: UserListResponse?
    var userExistResponse: UserExistResponse?
    var authResponse: AuthResponse?
    var shouldReturnError: Bool = false
    var commError: CommError?
    
    func setInvitationListResponse(_ invitationListResponse: InvitationListResponse?) {
        self.invitationListResponse = invitationListResponse
    }
    
    func setInvitationResponse(_ invitationResponse: InvitationResponse?) {
        self.invitationResponse = invitationResponse
    }
    
    func setWatchRelationshipListResponse(_ watchRelationshipListResponse: WatchRelationshipListResponse?) {
        self.watchRelationshipListResponse = watchRelationshipListResponse
    }
    
    func setSetCurrentWatchResponse(_ setCurrentWatchResponse: EmptyPayloadResponse?) {
        self.setCurrentWatchResponse = setCurrentWatchResponse
    }

    func setUserResponse(_ userResponse: UserResponse?) {
        self.userResponse = userResponse
    }
    
    func setUserListResponse(_ userListResponse: UserListResponse?) {
        self.userListResponse = userListResponse
    }
    
    func setUserExistResponse(_ userExistResponse: UserExistResponse?) {
        self.userExistResponse = userExistResponse
    }

    func setAuthResponse(_ authResponse: AuthResponse?) {
        self.authResponse = authResponse
    }
    
    func setShouldReturnError(_ shouldReturnError: Bool) {
        self.shouldReturnError = shouldReturnError
    }
    
    func setCommError(_ commError: CommError?) {
        self.commError = commError
    }
    
    // MARK: - mocked functions
    func getAllInvitations() async throws -> InvitationListResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let invitationListResponse, !shouldReturnError {
            return invitationListResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
    
    func getWatchRelationships() async throws -> WatchRelationshipListResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let watchRelationshipListResponse, !shouldReturnError {
            return watchRelationshipListResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
    
    func sendInvitation(email: String, message: String) async throws -> InvitationResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let invitationResponse, !shouldReturnError {
            return invitationResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
    
    func setCurrentWatch(relationshipId: Int) async throws -> EmptyPayloadResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let setCurrentWatchResponse, !shouldReturnError {
            return setCurrentWatchResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
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
    
    func updateUserInfo(newUserModel: UserModel) async throws -> UserResponse? {
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
    
    func checkUserExists(username: String) async throws -> UserExistResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let userExistResponse = userExistResponse, !shouldReturnError {
            return userExistResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
    
    func sendVerificationEmail(username: String) async throws -> AuthResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let authResponse = authResponse, !shouldReturnError {
            return authResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
    
    func verifyEmail(username: String, code: String) async throws -> UserResponse? {
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
    
    func completeRegister(username: String, password: String) async throws -> AuthResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let authResponse = authResponse, !shouldReturnError {
            return authResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
}
