//
//  StringUtil.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 09/04/2025.
//

import Foundation
import UIKit

struct StringUtil {
    static let shared = StringUtil()
    
    private init() {}
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: emailRegex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func initials(from email: String) -> String {
        let localPart = email.split(separator: "@").first.map(String.init) ?? email

        return localPart
            .split(whereSeparator: { $0 == "." || $0 == "_" || $0 == "-" })
            .compactMap { $0.first.map { String($0).uppercased() } }
            .joined()
    }
    
    func name(from email: String) -> String {
        let localPart = email.split(separator: "@").first.map(String.init) ?? email
        
        return localPart
            .split(whereSeparator: { $0 == "." || $0 == "_" || $0 == "-" })
            .joined(separator: " ")
    }
    
    @MainActor
    func getDeviceId() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
}
