//
//  BiometricsUtil.swift
//  AbcTest
//
//  Created by Armstrong Liu on 15/03/2025.
//

import Foundation
import LocalAuthentication
import OSLog

enum BiometryError: Error, Equatable {
    case notEnroll
    case notAvailable
    case other(Error)
    
    static func == (lhs: BiometryError, rhs: BiometryError) -> Bool {
        switch (lhs, rhs) {
        case (.notEnroll, .notEnroll):
            return true
        case (.notAvailable, .notAvailable):
            return true
        case (.other(let lhsError), .other(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

@MainActor
protocol LAContextProtocol {
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool
}

extension LAContext: LAContextProtocol {}

protocol BiometricsUtilProtocol {
    func canUseBiometrics() async throws -> Bool
}

@MainActor
struct BiometricsUtil: BiometricsUtilProtocol {
    private let contextProvider: LAContextProtocol
    static let shared = BiometricsUtil(contextProvider: LAContext())
    
    init(contextProvider: LAContextProtocol = LAContext()) {
        self.contextProvider = contextProvider
    }
    
    func canUseBiometrics() async throws -> Bool {
        let context = contextProvider
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let laError = error as? LAError {
                switch laError.code {
                case .biometryNotEnrolled:
                    throw BiometryError.notEnroll
                case .biometryNotAvailable:
                    throw BiometryError.notAvailable
                case .userCancel:
                    return false
                default:
                    throw BiometryError.other(laError)
                }
            }
            
            return false
        }
        
        let reason = "Please use FaceID or TouchID to access the secure info"
        do {
            let result = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return result
        } catch let laError as LAError {
            if laError.code != .userCancel {
                throw BiometryError.other(laError)
            }
        }
        
        return false
    }
}
