//
//  BaseLogger.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 26/03/2026.
//

import Foundation
import OSLog

protocol Loggable {
    var logger: Logger { get }
}

extension Loggable {
    var logger: Logger {
        Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "TrackerParent",
            category: String(describing: Self.self)
        )
    }
}
