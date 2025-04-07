//
//  MockBiometricsUtil.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 07/04/2025.
//

import Foundation

final class MockBiometricsUtil: BiometricsUtilProtocol {
    var canAuthenticate: Bool = true
    
    func canUseBiometrics() async throws -> Bool {
        return canAuthenticate
    }
}
