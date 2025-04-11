//
//  Endpoint.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 16/03/2025.
//

import Foundation

enum Endpoint {
    static let userURL = "https://intensivecredentialdev.azurewebsites.net/api"
    static let locationURL = "https://intensivelocationdev.azurewebsites.net/api"
//    static let userURL = "https://intensivecredentialprod.azurewebsites.net/api"
//    static let locationURL = "https://intensivelocationprod.azurewebsites.net/api"

    case login
    case userInfo(String)
    case allUsers
    case userExists(String)
    case sendVerificationEmail
    case verifyEmail
    case completeRegister
    case tracks
    case allTracks
    case setting
    case addSetting
    case updateSetting
    case deleteSetting
    
    var urlString: String {
        switch self {
        case .login:
            return "\(Endpoint.userURL)/identity/token"
        case .userInfo(let username):
            return "\(Endpoint.userURL)/identity/user?username=\(username)"
        case .allUsers:
            return "\(Endpoint.userURL)/identity/user/all"
        case .userExists(let username):
            return "\(Endpoint.userURL)/identity/user/exist?username=\(username)"
        case .sendVerificationEmail:
            return "\(Endpoint.userURL)/identity/user/create"
        case .verifyEmail:
            return "\(Endpoint.userURL)/identity/user/authenticate"
        case .completeRegister:
            return "\(Endpoint.userURL)/identity/user/password"
        case .tracks:
            return "\(Endpoint.locationURL)/geo/locations/user/bydate"
        case .allTracks:
            return "\(Endpoint.locationURL)/geo/locations/all"
        case .setting:
            return "\(Endpoint.locationURL)/geo/settings"
        case .addSetting:
            return "\(Endpoint.locationURL)/geo/setting/add"
        case .updateSetting:
            return "\(Endpoint.locationURL)/geo/setting/update"
        case .deleteSetting:
            return "\(Endpoint.locationURL)/geo/setting/delete"
        }
    }
}
