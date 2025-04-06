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
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockLoginService = MockLoginService()
        sut = AuthViewModel(loginService: mockLoginService)
    }

    override func tearDownWithError() throws {
        mockLoginService = nil
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
}
