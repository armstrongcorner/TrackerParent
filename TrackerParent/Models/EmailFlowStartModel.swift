//
//  EmailFlowStartModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 11/04/2026.
//

import Foundation

enum EmailFlowStartStep: String, Codable {
    case none = "none"
    case login = "login"
    case register = "register"
}

struct EmailFlowStartModel: Codable {
    let flowToken: String?
    let step: EmailFlowStartStep?
    let expiresIn: Int?
    let challengeRequired: Bool?
}

typealias EmailFlowStartResponse = BaseResponse<EmailFlowStartModel>
