//
//  UserViewModelTests.swift
//  TrackerParentTests
//
//  Created by Armstrong Liu on 14/04/2025.
//

import XCTest
@testable import TrackerParent

@MainActor
final class UserViewModelTests: XCTestCase {
    var sut: UserViewModel!
    var mockUserService: MockUserService!
    var mockKeyChainUtil: KeyChainUtil!
    var mockUserDefaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockUserService = MockUserService()
        mockKeyChainUtil = KeyChainUtil(bundleId: "com.example.TrackerParent")
        mockUserDefaults = UserDefaults(suiteName: "au.com.matrixthoughts.TrackerParent.mock") ?? .standard
        
        sut = UserViewModel(
            userService: mockUserService,
            keyChainUtil: mockKeyChainUtil,
            userDefaults: mockUserDefaults
        )
    }

    override func tearDownWithError() throws {
        mockUserService = nil
        mockKeyChainUtil = nil
        mockUserDefaults.removePersistentDomain(forName: "au.com.matrixthoughts.TrackerParent.mock")
        mockUserDefaults = nil
        sut = nil

        try super.tearDownWithError()
    }

    func testFetchUsersSuccess() async {
        // Given
        await mockUserService.setShouldReturnError(false)
        await mockUserService.setUserListResponse(mockUserListResponse)
        
        // When
        await sut.fetchUsers()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.fetchDataState, .done, "Fetch users should be successful.")
        XCTAssertNil(sut.errMsg, "Fetch users should succeed and no error message.")
        XCTAssertEqual(sut.users.count, mockUserListResponse.value?.count, "Fetched users count should match the mock response count.")
    }

    func testFetchUsersFailWithServerResponseError() async {
        // Given
        await mockUserService.setShouldReturnError(false)
        await mockUserService.setUserListResponse(mockUserListResponseWithFailureReason)
        
        // When
        await sut.fetchUsers()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.fetchDataState, .error, "Fetch users should be failure")
        XCTAssertEqual(sut.errMsg, CommError.serverReturnedError(mockUserListResponseWithFailureReason.failureReason ?? "").errorDescription, "Fetch users should be failed with server response error.")
    }
    
    func testFetchUsersFailWithUnknownError() async {
        // Given
        await mockUserService.setUserListResponse(nil)
        
        // When
        await sut.fetchUsers()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.fetchDataState, .error, "Fetch users should be failure")
        XCTAssertEqual(sut.errMsg, CommError.unknown.errorDescription, "Fetch users should be failed with unknown error.")
    }
    
    func testDeactivateUserSuccess() async {
        // Given
        await mockUserService.setShouldReturnError(false)
        await mockUserService.setUserResponse(mockUserResponse3)
        
        // When
        await sut.deactivateUser()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.fetchDataState, .done, "Deactivate user should be successful")
        XCTAssertNil(sut.errMsg, "Deactivate user should succeed and no error message.")
    }

    func testDeactivateUserFailWithServerResponseError() async {
        // Given
        await mockUserService.setShouldReturnError(false)
        await mockUserService.setUserResponse(mockUserResponseWithFailureReason)
        
        // When
        await sut.deactivateUser()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.fetchDataState, .error, "Deactivate user should be failure")
        XCTAssertEqual(sut.errMsg, CommError.serverReturnedError(mockUserResponseWithFailureReason.failureReason ?? "").errorDescription, "Deactivate user should be failed with server response error.")
    }
    
    func testLogoutSuccess() async {
        do {
            // Given
            mockUserDefaults.set(mockUser1.userName ?? "test@example.com", forKey: "username")
            try mockKeyChainUtil.saveObject(account: mockUser1.userName ?? "test@example.com", object: mockAuth1)
            
            // When
            sut.logout()
            
            // Then
            let loadedUserName = mockUserDefaults.string(forKey: "username")
            XCTAssertNil(loadedUserName, "Logout should remove username from UserDefaults")
            let loadedAuthModel = try mockKeyChainUtil.loadObject(account: mockUser1.userName ?? "test@example.com", type: AuthModel.self)
            XCTAssertNil(loadedAuthModel, "Logout should remove authModel from KeyChain")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
