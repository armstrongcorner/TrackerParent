//
//  TrackViewModelTests.swift
//  TrackerParentTests
//
//  Created by Armstrong Liu on 16/04/2025.
//

import XCTest
@testable import TrackerParent

@MainActor
final class TrackViewModelTests: XCTestCase {
    var sut: TrackViewModel!
    var mockTrackService: MockTrackService!
    var mockUserDefaults: UserDefaults!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockTrackService = MockTrackService()
        mockUserDefaults = UserDefaults(suiteName: "au.com.matrixthoughts.TrackerParent.mock") ?? .standard
        
        sut = TrackViewModel(trackService: mockTrackService, userDefaults: mockUserDefaults)
    }

    override func tearDownWithError() throws {
        mockTrackService = nil
        mockUserDefaults.removePersistentDomain(forName: "au.com.matrixthoughts.TrackerParent.mock")
        mockUserDefaults = nil
        sut = nil

        try super.tearDownWithError()
    }

    func testFetchTrackSuccess() async {
        // Given
        await mockTrackService.setShouldReturnError(false)
        await mockTrackService.setLocationResponse(mockLocationResponse)

        // When
        await sut.fetchTrack(username: mockUser1.userName, fromDate: .now, toDate: .now)
        let totalLocationCount = sut.tracks.compactMap(\.count).reduce(0, +)

        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.fetchDataState, .done, "Fetch track should be successful.")
        XCTAssertNil(sut.errMsg, "Fetch track should succeed and no error message.")
        XCTAssertEqual(sut.tracks.count, 2, "Fetch track should return 2 tracks.")
        XCTAssertEqual(totalLocationCount, mockLocationResponse.value?.count, "")
    }

    func testFetchUsersFailWithServerResponseError() async {
        // Given
        await mockTrackService.setShouldReturnError(false)
        await mockTrackService.setLocationResponse(mockLocationResponseWithFailureReason)
        
        // When
        await sut.fetchTrack(username: mockUser1.userName, fromDate: .now, toDate: .now)
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.fetchDataState, .error, "Fetch track should be failure")
        XCTAssertEqual(sut.errMsg, CommError.serverReturnedError(mockUserListResponseWithFailureReason.failureReason ?? "").errorDescription, "Fetch track should be failed with server response error.")
    }
    
    func testFetchUsersFailWithUnknownError() async {
        // Given
        await mockTrackService.setLocationResponse(nil)
        
        // When
        await sut.fetchTrack(username: mockUser1.userName, fromDate: .now, toDate: .now)
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.fetchDataState, .error, "Fetch track should be failure")
        XCTAssertEqual(sut.errMsg, CommError.unknown.errorDescription, "Fetch track should be failed with unknown error.")
    }
}
