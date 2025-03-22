//
//  LocationModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/19.
//

import Foundation

struct LocationModel: Codable, Hashable {
    let id: Int
    let userName: String
    let latitude: String
    let longitude: String
    let speed: String?
    let direction: String?
    let dateTimeOcurred: String
    let createdDateTime: String
    
    func toDictionary() -> [String: Any?] {
        return [
            "id": id,
            "userName": userName,
            "latitude": latitude,
            "longitude": longitude,
            "speed": speed,
            "direction": direction,
            "dateTimeOcurred": dateTimeOcurred,
            "createdDateTime": createdDateTime
        ]
    }
}

typealias LocationResponse = BaseResponse<[LocationModel]>
