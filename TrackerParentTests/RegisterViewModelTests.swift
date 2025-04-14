//
//  RegisterViewModelTests.swift
//  TrackerParentTests
//
//  Created by Armstrong Liu on 13/04/2025.
//

import XCTest
@testable import TrackerParent

@MainActor
final class RegisterViewModelTests: XCTestCase {
    var sut: RegisterViewModel!
    var mockLoginService: MockLoginService!
    var mockUserService: MockUserService!
    var mockKeyChainUtil: MockKeyChainUtil!
    var mockUserDefaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockLoginService = MockLoginService()
        mockUserService = MockUserService()
        mockKeyChainUtil = MockKeyChainUtil()
        mockUserDefaults = UserDefaults(suiteName: "au.com.matrixthoughts.TrackerParent.mock") ?? .standard
        
        sut = RegisterViewModel(
            userService: mockUserService,
            loginService: mockLoginService,
            keyChainUtil: mockKeyChainUtil,
            userDefaults: mockUserDefaults
        )
    }

    override func tearDownWithError() throws {
        mockUserService = nil
        mockLoginService = nil
        mockKeyChainUtil = nil
        mockUserDefaults.removePersistentDomain(forName: "au.com.matrixthoughts.TrackerParent.mock")
        mockUserDefaults = nil
        sut = nil

        try super.tearDownWithError()
    }

    func testRequestVerificationCodeSuccess() async {
        // Given
        sut.email = "test@example.com"
        await mockUserService.setUserExistResponse(mockUserExistResponseFalse)
        await mockLoginService.setShouldReturnError(false)
        await mockLoginService.setAuthResponse(mockAuthResponse2)
        await mockUserService.setShouldReturnError(false)
        await mockUserService.setAuthResponse(mockAuthResponse1)
        
        // When
        await sut.requestVerificationCode()
        let _ = try? mockKeyChainUtil.saveObject(service: "com.example.TrackerParent", account: sut.email, object: mockAuth1)
        let loadedAuthModel = try? mockKeyChainUtil.loadObject(service: "com.example.TrackerParent", account: sut.email, type: AuthModel.self)
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.registerState, .none, "Sending verification code should succeed but the registration state should still be none.")
        XCTAssertNil(sut.errMsg, "Sending verification code should succeed and no error message.")
        XCTAssertEqual(loadedAuthModel?.token, mockAuth1.token, "Keychain should store the auth token correctly.")
    }
    
    func testRequestVerificationCodeFailWithEmptyEmail() async {
        // Given
        sut.email = ""
        
        // When
        await sut.requestVerificationCode()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.registerState, .failure, "Register state should be failure.")
        XCTAssertEqual(sut.errMsg, RegisterError.emptyEmail.errorDescription, "Register should be failed with empty email error.")
    }
    
    func testRequestVerificationCodeFailWithInvalidEmail() async {
        // Given
        sut.email = "invalid_format_email"
        
        // When
        await sut.requestVerificationCode()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.registerState, .failure, "Register state should be failure.")
        XCTAssertEqual(sut.errMsg, RegisterError.invalidEmail.errorDescription, "Register should be failed with invalid format email error.")
    }
    
    func testRequestVerificationCodeFailWithUserUnavailable() async {
        // Given
        sut.email = "test@example.com"
        await mockUserService.setUserExistResponse(mockUserExistResponseTrue)
        
        // When
        await sut.requestVerificationCode()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.registerState, .failure, "Register state should be failure.")
        XCTAssertEqual(sut.errMsg, "\(sut.email) is unavailable", "Register should be failed with user unavailable error.")
    }
    
    func testRequestVerificationCodeFailWithServerResponseError() async {
        // Given
        sut.email = "test@example.com"
        await mockUserService.setUserExistResponse(mockUserExistResponseFalse)
        await mockLoginService.setShouldReturnError(false)
        await mockLoginService.setAuthResponse(mockAuthResponse2)
        await mockUserService.setShouldReturnError(false)
        await mockUserService.setAuthResponse(mockAuthResponseWithFailureReason)

        // When
        await sut.requestVerificationCode()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.registerState, .failure, "Register state should be failure.")
        XCTAssertEqual(sut.errMsg, CommError.serverReturnedError(mockAuthResponseWithFailureReason.failureReason ?? "").errorDescription, "Register should be failed with server response error.")
    }
    
    func testRequestVerificationCodeFailWithUnknownError() async {
        // Given
        sut.email = "test@example.com"
        await mockUserService.setUserExistResponse(mockUserExistResponseFalse)
        await mockLoginService.setShouldReturnError(false)
        await mockLoginService.setAuthResponse(mockAuthResponse2)
        await mockUserService.setShouldReturnError(false)
        await mockUserService.setAuthResponse(nil)

        // When
        await sut.requestVerificationCode()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.registerState, .failure, "Register state should be failed.")
        XCTAssertEqual(sut.errMsg, CommError.unknown.errorDescription, "Register should be failed with unknown error.")
    }
    
    func testVerifyEmailSuccess() async {
        // Given
        sut.email = "test@example.com"
        sut.verificationCode = "123456"
        await mockUserService.setShouldReturnError(false)
        await mockUserService.setUserResponse(mockUserResponse1)
        
        // When
        await sut.verifyEmail()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.registerState, .success, "Register state should be success with verifying code.")
        XCTAssertNil(sut.errMsg, "Verifying code should succeed and no error message.")
    }
    
    func testVerifyEmailFailWithNoCode() async {
        // Given
        sut.email = "test@example.com"
        sut.verificationCode = ""
        
        // When
        await sut.verifyEmail()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.registerState, .failure, "Register state should be failure.")
        XCTAssertEqual(sut.errMsg, RegisterError.emptyVerificationCode.errorDescription, "Register verifying code should be failed with empty code error.")
    }
    
    func testVerifyEmailFailWithInvalidCode() async {
        // Given
        sut.email = "test@example.com"
        sut.verificationCode = "654321"
        await mockUserService.setShouldReturnError(false)
        await mockUserService.setUserResponse(mockUserResponseWithFailureReason)

        // When
        await sut.verifyEmail()
        
        // Then
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.registerState, .failure, "Register state should be failure.")
        XCTAssertEqual(sut.errMsg, CommError.serverReturnedError(mockAuthResponseWithFailureReason.failureReason ?? "").errorDescription, "Register verifying code should be failed with code not match error.")
    }
}
