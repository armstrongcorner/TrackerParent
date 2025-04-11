//
//  UserModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/18.
//

import Foundation

struct UserModel: Codable, Hashable {
    var id: Int?
    var userName: String?
    var password: String?
    var photo: String?
    var role: String?
    var mobile: String?
    var email: String?
    var serviceLevel: Int?
    var tokenDurationInMin: Int?
    var isActive: Bool?
    var createdDateTime: String?
    var updatedDateTime: String?
    var createdBy: String?
    var updatedBy: String?
    
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
typealias UserListResponse = BaseResponse<[UserModel]>
typealias UserExistResponse = BaseResponse<Bool>
