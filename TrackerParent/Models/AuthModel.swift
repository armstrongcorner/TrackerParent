//
//  AuthModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 21/03/2026.
//

import Foundation

//struct AuthModel: Codable {
//    let token: String
//    let userRole: String
//    let validInMins: Int
//    let validUntilUTC: String
//}

struct AuthModel: Codable {
    let accessToken: String?
    let accessTokenExpiresAt: String?
    let expiresIn: Int?
    let refreshToken: String?
    let user: UserModel?
}

typealias AuthResponse = BaseResponse<AuthModel>
