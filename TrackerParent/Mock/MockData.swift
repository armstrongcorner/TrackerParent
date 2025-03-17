//
//  MockData.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 16/03/2025.
//

import Foundation

let mockAuthResponse = AuthResponse(value: AuthModel(token: "123456", validInMins: 20, validUntilUTC: "2025-03-26T01:29:38.946042Z"), failureReason: nil, isSuccess: true)
let mockAuthResponseWithFailureReason = AuthResponse(value: nil, failureReason: "Server response error message", isSuccess: false)
