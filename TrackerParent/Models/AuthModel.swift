//
//  AuthModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 15/03/2025.
//

import Foundation

struct AuthModel: Codable {
    let token: String
    let validInMins: Int
    let validUntilUTC: String
}

typealias AuthResponse = BaseResponse<AuthModel>
