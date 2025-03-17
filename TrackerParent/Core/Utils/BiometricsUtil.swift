//
//  BiometricsUtil.swift
//  AbcTest
//
//  Created by Armstrong Liu on 15/03/2025.
//

import Foundation
import LocalAuthentication

struct BiometricsUtil {
    static let shared = BiometricsUtil()
    
    private init() {}
    
    func canUseBiometrics() async throws -> Bool {
        let context = LAContext()
        var error: NSError?
        
        // Check device support biometrics or not
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            let error = error ?? NSError(domain: #function, code: -1, userInfo: [NSLocalizedDescriptionKey: "Device not support biometrics"])
            throw error
        }
        
        let reason = "Please use FaceID or TouchID to access the secure info"
        let result = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
        return result
    }
}
