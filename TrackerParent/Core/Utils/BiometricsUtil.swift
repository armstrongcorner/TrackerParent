//
//  BiometricsUtil.swift
//  AbcTest
//
//  Created by Armstrong Liu on 15/03/2025.
//

import Foundation
import LocalAuthentication
import OSLog

enum BiometryError: Error {
    case notEnroll
    case notAvailable
    case other(Error)
}

struct BiometricsUtil {
    static let shared = BiometricsUtil()
    
    private init() {}
    
    func canUseBiometrics() async throws -> Bool {
        let context = LAContext()
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
