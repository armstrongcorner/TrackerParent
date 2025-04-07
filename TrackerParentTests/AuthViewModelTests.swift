//
//  AuthViewModelTests.swift
//  TrackerParentTests
//
//  Created by Armstrong Liu on 13/03/2025.
//

import XCTest
@testable import TrackerParent

@MainActor
final class AuthViewModelTests: XCTestCase {
    var sut: AuthViewModel!
    var mockLoginService: MockLoginService!
    var mockUserService: MockUserService!
    var mockBiometricsUtil: MockBiometricsUtil!
    var mockKeyChainUtil: MockKeyChainUtil!
    var mockUserDefaults: UserDefaults!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockLoginService = MockLoginService()
        mockUserService = MockUserService()
        mockBiometricsUtil = MockBiometricsUtil()
        mockKeyChainUtil = MockKeyChainUtil()
        mockUserDefaults = UserDefaults(suiteName: "au.com.matrixthoughts.TrackerParent.mock") ?? .standard
        
        sut = AuthViewModel(
            loginService: mockLoginService,
            userService: mockUserService,
            keyChainUtil: mockKeyChainUtil,
            biometricsUtil: mockBiometricsUtil,
            userDefaults: mockUserDefaults
        )
    }

    override func tearDownWithError() throws {
        mockLoginService = nil
        mockUserService = nil
        mockBiometricsUtil = nil
        mockKeyChainUtil = nil
        mockUserDefaults.removePersistentDomain(forName: "au.com.matrixthoughts.TrackerParent.mock")
        mockUserDefaults = nil
        sut = nil
        
        try super.tearDownWithError()
    }

    func testLoginSuccess() async {
        // Given
        sut.username = "test_username"
        sut.password = "test_password"
        await mockLoginService.setShouldReturnError(false)
        await mockLoginService.setAuthResponse(mockAuthResponse)
        
        // When
        await sut.login()
        
        // Then
        XCTAssertEqual(sut.loginState, .success, "Login should be successful.")
        XCTAssertNil(sut.errMsg, "Login successful, error message should be nil.")
    }
    
    func testLoginFailureWithInvalidCredentials() async {
        // Given
        sut.username = "test_username"
        sut.password = "wrong_password"
        await mockLoginService.setShouldReturnError(true)
        await mockLoginService.setLoginError(.invalidCredentials)
        
        // When
        await sut.login()
        
        // Then
        XCTAssertEqual(sut.loginState, .failure, "Login should be failed.")
        XCTAssertEqual(sut.errMsg, LoginError.invalidCredentials.errorDescription, "Login failed with invalid credentails.")
    }
    
    func testLoginFailWithEmptyUsername() async {
        // Given
        sut.username = ""
        sut.password = "test_password"
        
        // When
        await sut.login()
        
        // Then
        XCTAssertEqual(sut.loginState, .failure, "Login should be failed.")
        XCTAssertEqual(sut.errMsg, LoginError.emptyUsername.errorDescription, "Login should be failed with empty username.")
    }
    
    func testLoginFailWithEmptyPassword() async {
        // Given
        sut.username = "test_username"
        sut.password = ""
        
        // When
        await sut.login()
        
        // Then
        XCTAssertEqual(sut.loginState, .failure, "Login should be failed.")
        XCTAssertEqual(sut.errMsg, LoginError.emptyPassword.errorDescription, "Login should be failed with empty password.")
    }
    
    func testLoginFailWithUnknownError() async {
        // Given
        sut.username = "test_username"
        sut.password = "test_password"
        await mockLoginService.setAuthResponse(nil)
        await mockLoginService.setShouldReturnError(false)
        
        // When
        await sut.login()
        
        // Then
        XCTAssertEqual(sut.loginState, .failure, "Login should be failed.")
        XCTAssertEqual(sut.errMsg, CommError.unknown.errorDescription, "Login failed with unknown error.")
    }
    
    func testLoginFailWithServerResponseError() async {
        // Given
        sut.username = "test_username"
        sut.password = "test_password"
        await mockLoginService.setAuthResponse(mockAuthResponseWithFailureReason)
        await mockLoginService.setShouldReturnError(false)
        
        // When
        await sut.login()
        
        // Then
        XCTAssertEqual(sut.loginState, .failure, "Login should be failed.")
        XCTAssertEqual(sut.errMsg, CommError.serverReturnedError(mockAuthResponseWithFailureReason.failureReason ?? "").errorDescription, "Login failed with server response error.")
    }
    
    func testLoginWithFaceIdSuccess() async {
        do {
            // Given
            try mockKeyChainUtil.saveObject(service: "com.example.TrackerParent", account: mockUser1.userName ?? "test_username", object: mockAuth1)
            mockBiometricsUtil.canAuthenticate = true
            mockUserDefaults.set(mockUser1.userName, forKey: "username")
            await mockUserService.setShouldReturnError(false)
            await mockUserService.setCommError(nil)
            await mockUserService.setUserResponse(mockUserResponse1)
            
            // When
            await sut.loginWithFaceId()
            
            // Then
            XCTAssertEqual(sut.loginState, .success, "Login with FacdId should be success.")
            XCTAssertEqual(sut.role, mockUser1.role, "The retrieved user role should be correct.")
            XCTAssertNil(sut.errMsg, "Success login should not have error message.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLoginWithFaceIdAuthenticationFailure() async {
        // Given
        mockBiometricsUtil.canAuthenticate = false
        
        // When
        await sut.loginWithFaceId()
        
        // Then
        XCTAssertEqual(sut.loginState, .none, "Login with FaceId should not succeed.")
        XCTAssertNil(sut.errMsg, "Login with FaceId should not succeed, but no err msg returned.")
        
    }
    
    func testLoginWithFaceIdWithUserServiceServerResponseError() async {
        do {
            // Given
            try mockKeyChainUtil.saveObject(service: "com.example.TrackerParent", account: mockUser1.userName ?? "test_username", object: mockAuth1)
            mockBiometricsUtil.canAuthenticate = true
            mockUserDefaults.set(mockUser1.userName, forKey: "username")
            await mockUserService.setShouldReturnError(false)
            await mockUserService.setUserResponse(mockUserResponseWithFailureReason)
            
            // When
            await sut.loginWithFaceId()
            
            // Then
            XCTAssertEqual(sut.loginState, .failure, "Login with FaceId should be failed.")
            XCTAssertEqual(sut.errMsg, CommError.serverReturnedError(mockUserResponseWithFailureReason.failureReason ?? "").errorDescription, "Login with FaceId failed with server response error.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLoginWithFaceIdFailWithUserServiceUnknownError() async {
        do {
            try mockKeyChainUtil.saveObject(service: "com.example.TrackerParent", account: mockUser1.userName ?? "test_username", object: mockAuth1)
            mockBiometricsUtil.canAuthenticate = true
            mockUserDefaults.set(mockUser1.userName, forKey: "username")
            await mockUserService.setShouldReturnError(true)
            await mockUserService.setCommError(.unknown)
            
            // When
            await sut.loginWithFaceId()
            
            // Then
            XCTAssertEqual(sut.loginState, .failure, "Login with FaceId should be failed.")
            XCTAssertEqual(sut.errMsg, CommError.unknown.errorDescription, "Login failed with unknown error.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
