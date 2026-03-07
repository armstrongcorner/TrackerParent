//
//  LoginServiceTests.swift
//  TrackerParentTests
//
//  Created by Armstrong Liu on 17/04/2025.
//

import XCTest
@testable import TrackerParent
@testable import MTNetworkManager

final class LoginServiceTests: XCTestCase {
    var sut: LoginService!
    var mockApiClient: MockMTApiClient!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockApiClient = MockMTApiClient()
        sut = LoginService(apiClient: mockApiClient)
    }

    override func tearDownWithError() throws {
        mockApiClient = nil
        sut = nil
        
        try super.tearDownWithError()
    }

    func test_LoginService_login_shouldSuccess() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockAuthResponse1)
            
            // When
            let result = try await sut.login(username: mockUser1.userName ?? "", password: mockUser1.password ?? "")
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "Login should be successful.")
            XCTAssertEqual(result?.value?.token, mockAuth1.token, "Login result token should match mock token.")
            XCTAssertNil(result?.failureReason, "Login should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func test_LoginService_login_shouldFailed_withServerResponseError() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockAuthResponseWithFailureReason)
            
            // When
            let result = try await sut.login(username: mockUser1.userName ?? "", password: mockUser1.password ?? "")
            
            // Then
            XCTAssertEqual(result?.isSuccess, false, "Login should be failed.")
            XCTAssertNil(result?.value, "Login result value should be nil.")
            XCTAssertEqual(result?.failureReason, mockAuthResponseWithFailureReason.failureReason, "Login should be failed with failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func test_LoginService_login_shouldFailed_withEncodingError() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(MTApiError.encodingFailed("Failed to encode login request body"))
            
            // When
            let _ = try await sut.login(username: mockUser1.userName ?? "", password: mockUser1.password ?? "")
            XCTFail("Expected MTApiError.encodingFailed error to be thrown.")
        } catch let error as MTApiError {
            // Then
            XCTAssertEqual(error, .encodingFailed("Failed to encode login request body"), "Login should be failed due to request body encoded incorrectly.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func test_LoginService_login_shouldFailed_withDecodingError() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(MTApiError.decodingFailed("Failed to decode login response"))
            
            // When
            let _ = try await sut.login(username: mockUser1.userName ?? "", password: mockUser1.password ?? "")
            XCTFail("Expected MTApiError.decodingFailed error to be thrown.")
        } catch let error as MTApiError {
            // Then
            XCTAssertEqual(error, .decodingFailed("Failed to decode login response"), "Login should be failed due to response decoded incorrectly.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func test_LoginService_login_shouldFailed_withInvalidUrl() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(MTApiError.invalidUrl)
            
            // When
            let _ = try await sut.login(username: mockUser1.userName ?? "", password: mockUser1.password ?? "")
            XCTFail("Expected MTApiError.invalidUrl error to be thrown.")
        } catch let error as MTApiError {
            // Then
            XCTAssertEqual(error, .invalidUrl, "Login should be failed due to invalid url.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func test_LoginService_login_shouldFailed_withInvalidResponse() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(MTApiError.invalidResponse)
            
            // When
            let _ = try await sut.login(username: mockUser1.userName ?? "", password: mockUser1.password ?? "")
            XCTFail("Expected MTApiError.invalidResponse error to be thrown.")
        } catch let error as MTApiError {
            // Then
            XCTAssertEqual(error, .invalidResponse, "Login should be failed due to invalid response.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func test_LoginService_login_shouldFailed_withHttpErrorCode() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(MTApiError.httpErrorCode(404))
            
            // When
            let _ = try await sut.login(username: mockUser1.userName ?? "", password: mockUser1.password ?? "")
            XCTFail("Expected MTApiError.httpErrorCode error to be thrown.")
        } catch let error as MTApiError {
            // Then
            XCTAssertEqual(error, .httpErrorCode(404), "Login should be failed due to http error code.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
}
