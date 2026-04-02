//
//  InvitationModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 25/03/2026.
//

import Foundation

struct InvitationModel: Hashable, Codable {
    let id: Int?
    let ownerUserId: Int?
    let inviteeEmail: String?
    let inviteeUserId: Int?
    let status: String?
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
