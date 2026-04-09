//
//  WatchRelationshipModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 26/03/2026.
//

import Foundation

enum WatchRelationshipStatus: String, Codable, Hashable {
    case active = "active"
    case revoked = "revoked"
    case suspended = "suspended"
}

struct WatchRelationshipModel: Hashable, Codable {
    let id: Int?
    let ownerUserId: Int?
    let watchedUserId: Int?
    let invitationId: Int?
    let status: WatchRelationshipStatus?
    let activatedAt: String?
    let revokedAt: String?
    let createdAt: String?
    let updatedAt: String?
    let watchedUser: UserModel?
}

typealias WatchRelationshipListResponse = BaseResponse<[WatchRelationshipModel]>
