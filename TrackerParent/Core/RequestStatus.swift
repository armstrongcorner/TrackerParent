//
//  RequestStatus.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 29/03/2026.
//

import Foundation

enum CommReqState: Equatable {
    case none
    case loading
    case success
    case failure
}

struct RequestStatus: Equatable {
    var state: CommReqState = .none
    var errMsg: String? = nil
}
