//
//  SettingServiceTests.swift
//  TrackerParentTests
//
//  Created by Armstrong Liu on 18/04/2025.
//

import XCTest
@testable import TrackerParent

final class SettingServiceTests: XCTestCase {
    var sut: SettingService!
    var mockApiClient: MockApiClient!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockApiClient = MockApiClient()
        sut = SettingService(apiClient: mockApiClient)
    }

    override func tearDownWithError() throws {
        mockApiClient = nil
        sut = nil
        
        try super.tearDownWithError()
    }

    func testGetSettingsSuccess() async {
        do {
            // Given
            
            // When
            
            // Then
            
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
}
