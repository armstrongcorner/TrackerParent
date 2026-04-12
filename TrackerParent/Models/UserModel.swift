//
//  UserModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 21/03/2026.
//

import Foundation

struct UserModel: Codable, Hashable {
    var id: Int?
    var displayName: String?
    var email: String?
    var emailVerified: Bool?
    var disabled: Bool?
    var photoUrl: String?
    var firebaseUid: String?
    var createdAt: String?
    var updatedAt: String?
    var lastLoginAt: String?
    var signInProvider: String?
    var currentWatchRelationshipId: Int?
    var role: String?
    
    func toDictionary() -> [String: Any?] {
        return [
            "id": id,
            "displayName": displayName,
            "email": email,
            "emailVerified": emailVerified,
            "disabled": disabled,
            "photoUrl": photoUrl,
            "firebaseUid": firebaseUid,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "lastLoginAt": lastLoginAt,
            "signInProvider": signInProvider,
            "currentWatchRelationshipId": currentWatchRelationshipId,
            "role": role,
        ]
    }
}

typealias UserResponse = BaseResponse<UserModel>
typealias UserListResponse = BaseResponse<[UserModel]>
typealias UserExistResponse = BaseResponse<Bool>
