//
//  SettingModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/22.
//

import Foundation

struct SettingModel: Codable {
    var id: Int?
    var userName: String?
    var collectionFrequency: Int?
    var pushFrequency: Int?
    var distanceFilter: Int?
    var startTime: String?
    var endTime: String?
    var accuracy: String?
}

typealias AllSettingsResponse = BaseResponse<[SettingModel]>
typealias SettingResponse = BaseResponse<SettingModel>
