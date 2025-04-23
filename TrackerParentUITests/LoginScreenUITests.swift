//
//  LoginScreenUITests.swift
//  TrackerParentUITests
//
//  Created by Armstrong Liu on 21/04/2025.
//

import XCTest

final class LoginScreenUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments.append("-isUITesting")
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testExample() throws {
        
    }
}
