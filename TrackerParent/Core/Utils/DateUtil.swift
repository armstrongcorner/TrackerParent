//
//  DateUtil.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/19.
//

import Foundation

struct DateUtil {
    static let shared = DateUtil()
    
    private init() {}
    
    func convertStandardDateTimeStr(iso8601String: String) -> String? {
        guard let date = dateForISO8601Str(iso8601String) else {
            return nil
        }
        
        let targetFormatter = DateFormatter()
        targetFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return targetFormatter.string(from: date)
    }
    
    func minutesBetween(from: String, to: String) -> Int {
        let fromDate = dateForISO8601Str(from) ?? Date.distantPast
        let toDate = dateForISO8601Str(to) ?? Date.now
        
        let secondsDifference = fromDate.distance(to: toDate)
        return Int(secondsDifference / 60)
    }
    
    private func dateForISO8601Str(_ iso8601String: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: iso8601String)
    }
}
