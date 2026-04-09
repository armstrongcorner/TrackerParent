//
//  InvitationModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 25/03/2026.
//

import Foundation

enum InvitationStatus: String, Codable, Hashable {
    case accepted = "accepted"
    case pending = "pending"
    case declined = "declined"
    case revoked = "revoked"
    case expired = "expired"
}

struct InvitationModel: Hashable, Codable {
    let id: Int?
    let ownerUserId: Int?
    let inviteeEmail: String?
    let inviteeUserId: Int?
    let status: InvitationStatus?
    let message: String?
    let expiresAt: String?
    let acceptedAt: String?
    let declinedAt: String?
    let revokedAt: String?
    let createdAt: String?
    let updatedAt: String?
    let ownerUser: UserModel?
    let inviteeUser: UserModel?
}

typealias InvitationResponse = BaseResponse<InvitationModel>
typealias InvitationListResponse = BaseResponse<[InvitationModel]>
