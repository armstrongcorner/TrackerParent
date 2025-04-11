//
//  StringUtil.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 09/04/2025.
//

import Foundation

struct StringUtil {
    static let shared = StringUtil()
    
    private init() {}
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: emailRegex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
