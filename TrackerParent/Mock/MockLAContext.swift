//
//  MockLAContext.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 06/04/2025.
//

import Foundation
import LocalAuthentication

@MainActor
class MockLAContext: LAContextProtocol {
    var canEvaluate: Bool = true
    var evalucateResult: Bool = true
    var errorToThrow: LAError?
    
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        if !canEvaluate {
            error?.pointee = errorToThrow as NSError?
        }
        return canEvaluate
    }
    
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool {
        if let error = errorToThrow {
            throw error
        }
        return evalucateResult
    }
}
