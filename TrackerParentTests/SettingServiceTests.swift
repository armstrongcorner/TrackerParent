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
            await mockApiClient.setMockResponse(mockAllSettingsResponse)
            
            // When
            let result = try await sut.getSettings()
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "Get settings should be successful.")
            XCTAssertEqual(result?.value?.count, mockAllSettingsResponse.value?.count, "Get settings should return the correct number of locations.")
            XCTAssertNil(result?.failureReason, "Get settings should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testGetSettingsFailWithServerResponseError() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockAllSettingsResponseWithFailureReason)
            
            // When
            let result = try await sut.getSettings()
            
            // Then
            XCTAssertEqual(result?.isSuccess, false, "Get settings should be failed.")
            XCTAssertNil(result?.value, "Get settings result value should be nil.")
            XCTAssertEqual(result?.failureReason, mockAllSettingsResponseWithFailureReason.failureReason, "Get settings result should be failed with failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }

    func testAddSettingSuccess() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockSettingResponse)
            
            // When
            let result = try await sut.addSetting(newSetting: mockSetting1)
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "Add setting should be successful.")
            XCTAssertEqual(result?.value?.userName, mockSettingResponse.value?.userName, "Add setting result value should be correct.")
            XCTAssertNil(result?.failureReason, "Add setting should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testAddSettingFailWithServerResponseError() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockSettingResponseWithFailureReason)
            
            // When
            let result = try await sut.addSetting(newSetting: mockSetting1)
            
            // Then
            XCTAssertEqual(result?.isSuccess, false, "Add setting should be failed.")
            XCTAssertNil(result?.value, "Add setting result value should be nil.")
            XCTAssertEqual(result?.failureReason, mockSettingResponseWithFailureReason.failureReason, "Add setting result should be failed with failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }

    func testUpdateSettingSuccess() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockSettingResponse)
            
            // When
            let result = try await sut.updateSetting(newSetting: mockSetting1)
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "Update setting should be successful.")
            XCTAssertEqual(result?.value?.userName, mockSettingResponse.value?.userName, "Update setting result value should be correct.")
            XCTAssertNil(result?.failureReason, "Update setting should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testUpdateSettingFailWithServerResponseError() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockSettingResponseWithFailureReason)
            
            // When
            let result = try await sut.addSetting(newSetting: mockSetting1)
            
            // Then
            XCTAssertEqual(result?.isSuccess, false, "Update setting should be failed.")
            XCTAssertNil(result?.value, "Update setting result value should be nil.")
            XCTAssertEqual(result?.failureReason, mockSettingResponseWithFailureReason.failureReason, "Update setting result should be failed with failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }

    func testDeleteSettingSuccess() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockDeleteSettingResponse)
            
            // When
            let result = try await sut.deleteSetting(newSetting: mockSetting1)
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "Delete setting should be successful.")
            XCTAssertEqual(result?.value, mockDeleteSettingResponse.value, "Delete setting result value should be correct.")
            XCTAssertNil(result?.failureReason, "Delete setting should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testDeleteSettingFailWithServerResponseError() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockDeleteSettingResponseWithFailureReason)
            
            // When
            let result = try await sut.deleteSetting(newSetting: mockSetting1)
            
            // Then
            XCTAssertEqual(result?.isSuccess, false, "Delete setting should be failed.")
            XCTAssertNil(result?.value, "Delete setting result value should be nil.")
            XCTAssertEqual(result?.failureReason, mockDeleteSettingResponseWithFailureReason.failureReason, "Delete setting result should be failed with failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
}
