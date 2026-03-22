//
//  UserModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 21/03/2026.
//

import Foundation

//struct UserModel: Codable, Hashable {
//    var id: Int?
//    var userName: String?
//    var password: String?
//    var photo: String?
//    var role: String?
//    var mobile: String?
//    var email: String?
//    var serviceLevel: Int?
//    var tokenDurationInMin: Int?
//    var isActive: Bool?
//    var createdDateTime: String?
//    var updatedDateTime: String?
//    var createdBy: String?
//    var updatedBy: String?
//    
//    func toDictionary() -> [String: Any?] {
//        return [
//            "id": id,
//            "userName": userName,
//            "password": password,
//            "photo": photo,
//            "role": role,
//            "mobile": mobile,
//            "email": email,
//            "serviceLevel": serviceLevel,
//            "tokenDurationInMin": tokenDurationInMin,
//            "isActive": isActive,
//            "createdDateTime": createdDateTime,
//            "updatedDateTime": updatedDateTime,
//            "createdBy": createdBy,
//            "updatedBy": updatedBy
//        ]
//    }
//}

struct UserModel: Codable, Hashable {
    var id: Int?
    var username: String?
    var password: String?
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
    var role: String?
    
    func toDictionary() -> [String: Any?] {
        return [
            "id": id,
            "username": username,
            "password": password,
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
            "role": role,
        ]
    }
}

typealias UserResponse = BaseResponse<UserModel>
typealias UserListResponse = BaseResponse<[UserModel]>
typealias UserExistResponse = BaseResponse<Bool>
