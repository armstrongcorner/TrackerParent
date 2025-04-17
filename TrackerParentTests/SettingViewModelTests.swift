//
//  SettingViewModelTests.swift
//  TrackerParentTests
//
//  Created by Armstrong Liu on 16/04/2025.
//

import XCTest
@testable import TrackerParent

@MainActor
final class SettingViewModelTests: XCTestCase {
    var sut: SettingViewModel!
    var mockSettingService: MockSettingService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockSettingService = MockSettingService()
        sut = SettingViewModel(settingService: mockSettingService)
    }

    override func tearDownWithError() throws {
        mockSettingService = nil
        sut = nil
        
        try super.tearDownWithError()
    }

    func testFetchSettingListSuccess() async {
        // Given
        await mockSettingService.setShouldReturnError(false)
        await mockSettingService.setAllSettingsResponse(mockAllSettingsResponse)
        
        // When
        await sut.fetchSettingList()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.fetchDataState, .done, "Fetch setting list should be successful.")
        XCTAssertNil(sut.errMsg, "Fetch setting list should succeed and no error message.")
        XCTAssertEqual(sut.settingList?.count, mockAllSettingsResponse.value?.count, "Fetched setting list count should match the mock response count.")
    }

    func testFetchSettingListFailWithServerResponseError() async {
        // Given
        await mockSettingService.setShouldReturnError(false)
        await mockSettingService.setAllSettingsResponse(mockAllSettingsResponseWithFailureReason)
        
        // When
        await sut.fetchSettingList()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.fetchDataState, .error, "Fetch setting list should be failure")
        XCTAssertEqual(sut.errMsg, CommError.serverReturnedError(mockAllSettingsResponseWithFailureReason.failureReason ?? "").errorDescription, "Fetch setting list should be failed with server response error.")
    }
    
    func testFetchSettingListFailWithUnknownError() async {
        // Given
        await mockSettingService.setAllSettingsResponse(nil)
        
        // When
        await sut.fetchSettingList()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.fetchDataState, .error, "Fetch setting list should be failure")
        XCTAssertEqual(sut.errMsg, CommError.unknown.errorDescription, "Fetch setting list should be failed with unknown error.")
    }

    func testAddSettingSuccess() async {
        // Given
        await mockSettingService.setShouldReturnError(false)
        await mockSettingService.setSettingResponse(mockSettingResponse)
        sut.settingList = []
        
        // When
        await sut.addNewSetting()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.addDataState, .done, "Add setting should be successful.")
        XCTAssertNil(sut.errMsg, "Add setting should succeed and no error message.")
        XCTAssertEqual(sut.settingList?.count, 1, "Setting list should have one item after adding.")
    }

    func testAddSettingFailWithServerResponseError() async {
        // Given
        await mockSettingService.setShouldReturnError(false)
        await mockSettingService.setSettingResponse(mockSettingResponseWithFailureReason)
        
        // When
        await sut.addNewSetting()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.addDataState, .error, "Add setting should be failure")
        XCTAssertEqual(sut.errMsg, CommError.serverReturnedError(mockSettingResponseWithFailureReason.failureReason ?? "").errorDescription, "Add setting should be failed with server response error.")
    }
    
    func testAddSettingFailWithUnknownError() async {
        // Given
        await mockSettingService.setSettingResponse(nil)

        // When
        await sut.addNewSetting()

        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.addDataState, .error, "Add setting should be failure")
        XCTAssertEqual(sut.errMsg, CommError.unknown.errorDescription, "Add setting should be failed with unknown error.")
    }

    func testUpdateSettingSuccess() async {
        // Given
        sut.settingList = [mockSetting1, mockSetting2]
        sut.currentSetting = SettingModel(
            id: mockSetting2.id,
            userName: mockSetting2.userName,
            collectionFrequency: mockSetting2.collectionFrequency,
            pushFrequency: mockSetting2.pushFrequency,
            distanceFilter: 100,
            startTime: mockSetting2.startTime,
            endTime: mockSetting2.endTime,
            accuracy: "Low"
        )
        await mockSettingService.setShouldReturnError(false)
        await mockSettingService.setSettingResponse(SettingResponse(value: sut.currentSetting, failureReason: nil, isSuccess: true))
        
        // When
        await sut.updateCurrentSetting()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.updateDataState, .done, "Update setting should be successful.")
        XCTAssertNil(sut.errMsg, "Update setting should succeed and no error message.")
        let updatedSetting = sut.settingList?.last
        XCTAssertEqual(updatedSetting?.distanceFilter, sut.currentSetting?.distanceFilter, "Updated distance filter should be same with current setting.")
        XCTAssertEqual(updatedSetting?.accuracy, sut.currentSetting?.accuracy, "Updated accuracy should be same with current setting.")
    }
    
    func testUpdateSettingFailWithServerResponseError() async {
        // Given
        await mockSettingService.setShouldReturnError(false)
        await mockSettingService.setSettingResponse(mockSettingResponseWithFailureReason)
        
        // When
        await sut.updateCurrentSetting()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.updateDataState, .error, "Update setting should be failure")
        XCTAssertEqual(sut.errMsg, CommError.serverReturnedError(mockSettingResponseWithFailureReason.failureReason ?? "").errorDescription, "Update setting should be failed with server response error.")
    }
    
    func testUpdateSettingFailWithUnknownError() async {
        // Given
        await mockSettingService.setSettingResponse(nil)

        // When
        await sut.updateCurrentSetting()

        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.updateDataState, .error, "Update setting should be failure")
        XCTAssertEqual(sut.errMsg, CommError.unknown.errorDescription, "Update setting should be failed with unknown error.")
    }

    func testDeleteSettingSuccess() async {
        // Given
        await mockSettingService.setShouldReturnError(false)
        await mockSettingService.setDeleteSettingResponse(mockDeleteSettingResponse)
        
        // When
        await sut.deleteCurrentSetting()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.deleteDataState, .done, "Delete setting should be successful.")
        XCTAssertNil(sut.errMsg, "Delete setting should succeed and no error message.")
    }

    func testDeleteSettingFailWithServerResponseError() async {
        // Given
        await mockSettingService.setShouldReturnError(false)
        await mockSettingService.setDeleteSettingResponse(mockDeleteSettingResponseWithFailureReason)
        
        // When
        await sut.deleteCurrentSetting()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.deleteDataState, .error, "Delete setting should be failure")
        XCTAssertEqual(sut.errMsg, CommError.serverReturnedError(mockDeleteSettingResponseWithFailureReason.failureReason ?? "").errorDescription, "Delete setting should be failed with server response error.")
    }
    
    func testDeleteSettingFailWithUnknownError() async {
        // Given
        await mockSettingService.setDeleteSettingResponse(nil)

        // When
        await sut.deleteCurrentSetting()

        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.deleteDataState, .error, "Delete setting should be failure")
        XCTAssertEqual(sut.errMsg, CommError.unknown.errorDescription, "Delete setting should be failed with unknown error.")
    }
}
