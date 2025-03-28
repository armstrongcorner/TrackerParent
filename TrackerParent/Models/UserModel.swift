//
//  UserModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/18.
//

import Foundation

struct UserModel: Codable {
    let id: Int?
    let userName: String?
    let password: String?
    let photo: String?
    let role: String?
    let mobile: String?
    let email: String?
    let serviceLevel: Int?
    let tokenDurationInMin: Int?
    let isActive: Bool?
    let createdDateTime: String?
    let updatedDateTime: String?
    let createdBy: String?
    let updatedBy: String?
    
    func toDictionary() -> [String: Any?] {
        return [
            "id": id,
            "userName": userName,
            "password": password,
            "photo": photo,
            "role": role,
            "mobile": mobile,
            "email": email,
            "serviceLevel": serviceLevel,
            "tokenDurationInMin": tokenDurationInMin,
            "isActive": isActive,
            "createdDateTime": createdDateTime,
            "updatedDateTime": updatedDateTime,
            "createdBy": createdBy,
            "updatedBy": updatedBy
        ]
    }
}

typealias UserResponse = BaseResponse<UserModel>
