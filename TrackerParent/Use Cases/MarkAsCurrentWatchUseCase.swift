//
//  MarkAsCurrentWatchUseCase.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 05/04/2026.
//

import Foundation

@MainActor
protocol MarkAsCurrentWatchUseCaseProtocol {
    func execute(relationshipId: Int, sessionManager: SessionManager) async throws
}

final class MarkAsCurrentWatchUseCase: MarkAsCurrentWatchUseCaseProtocol {
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    func execute(relationshipId: Int, sessionManager: SessionManager) async throws {
        guard let response = try await userService.setCurrentWatch(relationshipId: relationshipId) else {
            throw CommError.unknown
        }

        if response.isSuccess {
            sessionManager.updateCurrentWatchRelationshipId(relationshipId)
        } else if let failureReason = response.failureReason {
            throw CommError.serverReturnedError(failureReason)
        } else {
            throw CommError.unknown
        }
    }
}
