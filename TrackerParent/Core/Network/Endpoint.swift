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
    
    case login
    case userInfo(String)
    case tracks
    case allTracks
    case setting
    case updateSetting
    
    var urlString: String {
        switch self {
        case .login:
            return "\(Endpoint.userURL)/identity/token"
        case .userInfo(let username):
            return "\(Endpoint.userURL)/identity/user?username=\(username)"
        case .tracks:
            return "\(Endpoint.locationURL)/geo/locations/user"
        case .allTracks:
            return "\(Endpoint.locationURL)/geo/locations/all"
        case .setting:
            return "\(Endpoint.locationURL)/geo/settings"
        case .updateSetting:
            return "\(Endpoint.locationURL)/geo/setting/update"
        }
    }
}
