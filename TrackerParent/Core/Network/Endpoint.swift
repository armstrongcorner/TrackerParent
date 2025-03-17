//
//  Endpoint.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 16/03/2025.
//

import Foundation

enum Endpoint {
    static let userURL = "https://intensivecredentialdev.azurewebsites.net/api"
    
    case login
    
    var urlString: String {
        switch self {
        case .login:
            return "\(Endpoint.userURL)/identity/token"
        }
    }
}
