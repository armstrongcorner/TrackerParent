//
//  FirebaseSSOUseCase.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 19/04/2026.
//

import Foundation
import MTAuthHelper
import FirebaseAuth

@MainActor
protocol FirebaseSSOUseCaseProtocol {
    func execute(type: SSOType) async throws -> String
}

final class FirebaseSSOUseCase: FirebaseSSOUseCaseProtocol, Loggable {
    func execute(type: SSOType) async throws -> String {
        var authDataResult: AuthDataResult?
        switch type {
        case .apple:
            authDataResult = try await MTAuthHelper.shared.handleAppleSignIn()
        case .google:
            authDataResult = try await MTAuthHelper.shared.handleGoogleSignIn()
        }
        
        guard let authDataResult else {
            logger.debug("--- Empty Firebase auth data result ---")
            throw MTAuthError.unknown
        }
        
        return try await MTAuthHelper.shared.getIdToken(from: authDataResult.user)
    }
}
