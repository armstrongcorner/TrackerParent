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
    
    func getDateStr(date: Date) -> String? {
        let targetFormatter = DateFormatter()
        targetFormatter.dateFormat = "yyyy/MM/dd"
        return targetFormatter.string(from: date)
    }
    
    func getTimeStr(date: Date) -> String? {
        let targetFormatter = DateFormatter()
        targetFormatter.dateFormat = "HH:mm:ss"
        return targetFormatter.string(from: date)
    }

    func dateForISO8601Str(_ iso8601Str: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: iso8601Str)
    }
    
    func dateForTimeStr(_ timeStr: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.date(from: timeStr)
    }
    
    func convertToISO8601Str(date: Date) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoString = isoFormatter.string(from: date)
        return isoString
    }
    
    func startOfTheDate(date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }
    
    func endOfTheDate(date: Date) -> Date {
        let calendar = Calendar.current
        let startOfTheDate = startOfTheDate(date: date)
        let endOfTheDate = (calendar.date(byAdding: .day, value: 1, to: startOfTheDate) ?? Date.now).addingTimeInterval(-1)
        
        return endOfTheDate
    }
}
