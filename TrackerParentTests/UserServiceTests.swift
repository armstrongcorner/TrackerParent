//
//  UserServiceTests.swift
//  TrackerParentTests
//
//  Created by Armstrong Liu on 17/04/2025.
//

import XCTest
@testable import TrackerParent

final class UserServiceTests: XCTestCase {
    var sut: UserService!
    var mockApiClient: MockApiClient!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockApiClient = MockApiClient()
        sut = UserService(apiClient: mockApiClient)
    }

    override func tearDownWithError() throws {
        mockApiClient = nil
        sut = nil
        
        try super.tearDownWithError()
    }

    func testGetUserInfoSuccess() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockUserResponse1)
            
            // When
            let result = try await sut.getUserInfo(username: mockUser1.userName ?? "")
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "Get user info should be successful.")
            XCTAssertEqual(result?.value?.id, mockUser1.id, "Get user info id should match mock user id.")
            XCTAssertNil(result?.failureReason, "Get user info should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testGetUserInfoFailWithServerResponseError() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockUserResponseWithFailureReason)
            
            // When
            let result = try await sut.getUserInfo(username: mockUser1.userName ?? "")
            
            // Then
            XCTAssertEqual(result?.isSuccess, false, "Get user info should be failed.")
            XCTAssertNil(result?.value, "Get user info result value should be nil.")
            XCTAssertEqual(result?.failureReason, mockUserResponseWithFailureReason.failureReason, "Get user info should be failed with failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }

    func testGetUserInfoFailWithAnyApiError() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(ApiError.invalidUrl)
            
            // When
            let _ = try await sut.getUserInfo(username: mockUser1.userName ?? "")
            XCTFail("Expected ApiError.invalidUrl error to be thrown.")
        } catch let error as ApiError {
            // Then
            XCTAssertEqual(error, .invalidUrl, "Get user info should be failed due to invalid url.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testGetUserListSuccess() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockUserListResponse)
            
            // When
            let result = try await sut.getUserList()
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "Get user list should be successful.")
            XCTAssertEqual(result?.value?.count, mockUserListResponse.value?.count, "User list count should be equal to mock response count.")
            XCTAssertNil(result?.failureReason, "Get user list should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testGetUserListFailWithServerResponseError() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockUserListResponseWithFailureReason)
            
            // When
            let result = try await sut.getUserList()
            
            // Then
            XCTAssertEqual(result?.isSuccess, false, "Get user list should be failed.")
            XCTAssertNil(result?.value, "Get user list result value should be nil.")
            XCTAssertEqual(result?.failureReason, mockUserListResponseWithFailureReason.failureReason, "Get user list should be failed with failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }

    func testGetUserListFailWithAnyApiError() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(ApiError.decodingFailed("Failed to decode user list response"))
            
            // When
            let _ = try await sut.getUserList()
            XCTFail("Expected ApiError.decodingFailed error to be thrown.")
        } catch let error as ApiError {
            // Then
            XCTAssertEqual(error, .decodingFailed("Failed to decode user list response"), "Get user list should be failed due to response decoded incorrectly.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testUpdateUserInfoSuccess() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockUserResponse1)
            
            // When
            let result = try await sut.updateUserInfo(newUserModel: mockUser1)
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "Update user info should be successful.")
            XCTAssertEqual(result?.value?.id, mockUser1.id, "Update user info done but user id should not be changed.")
            XCTAssertNil(result?.failureReason, "Update user info should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testUpdateUserInfoFailWithServerResponseError() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockUserResponseWithFailureReason)
            
            // When
            let result = try await sut.updateUserInfo(newUserModel: mockUser1)
            
            // Then
            XCTAssertEqual(result?.isSuccess, false, "Update user info should be failed.")
            XCTAssertNil(result?.value, "Update user info result value should be nil.")
            XCTAssertEqual(result?.failureReason, mockUserResponseWithFailureReason.failureReason, "Update user info should be failed with failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }

    func testUpdateUserInfoFailWithAnyApiError() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(ApiError.encodingFailed("Failed to encode update user info request body"))
            
            // When
            let _ = try await sut.updateUserInfo(newUserModel: mockUser1)
            XCTFail("Expected ApiError.encodingFailed error to be thrown.")
        } catch let error as ApiError {
            // Then
            XCTAssertEqual(error, .encodingFailed("Failed to encode update user info request body"), "Update user info should be failed due to request body encoded incorrectly.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testCheckUserExistsTrueSuccess() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockUserExistResponseTrue)
            
            // When
            let result = try await sut.checkUserExists(username: mockUser1.userName ?? "")
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "User exist response should be successful.")
            XCTAssertEqual(result?.value, true, "This user should already exist.")
            XCTAssertNil(result?.failureReason, "Check user exist should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testCheckUserExistsFalseSuccess() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockUserExistResponseFalse)
            
            // When
            let result = try await sut.checkUserExists(username: mockUser1.userName ?? "")
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "User exist response should be successful.")
            XCTAssertEqual(result?.value, false, "This user should not exist in the system.")
            XCTAssertNil(result?.failureReason, "Check user exist should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testCheckUserExistsFailWithServerResponseError() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockUserExistResponseWithFailureReason)
            
            // When
            let result = try await sut.checkUserExists(username: mockUser1.userName ?? "")
            
            // Then
            XCTAssertEqual(result?.isSuccess, false, "Check user exist should be failed.")
            XCTAssertNil(result?.value, "Check user exist result value should be nil.")
            XCTAssertEqual(result?.failureReason, mockUserExistResponseWithFailureReason.failureReason, "Check user exist result should be failed with failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }

    func testSendVerificationEmailSuccess() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockAuthResponse1)
            
            // When
            let result = try await sut.sendVerificationEmail(username: mockUser1.userName ?? "")
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "Send verification email response should be successful.")
            XCTAssertEqual(result?.value?.token, mockAuth1.token, "Send verification email should return a valid token.")
            XCTAssertNil(result?.failureReason, "Send verification email should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testSendVerificationEmailFailWithServerResponseError() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockAuthResponseWithFailureReason)
            
            // When
            let result = try await sut.sendVerificationEmail(username: mockUser1.userName ?? "")
            
            // Then
            XCTAssertEqual(result?.isSuccess, false, "Send verification email should be failed.")
            XCTAssertNil(result?.value, "Send verification email result value should be nil.")
            XCTAssertEqual(result?.failureReason, mockAuthResponseWithFailureReason.failureReason, "Send verification email result should be failed with failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }

    func testSendVerificationEmailFailWithAnyApiError() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(ApiError.invalidResponse)
            
            // When
            let _ = try await sut.sendVerificationEmail(username: mockUser1.userName ?? "")
            XCTFail("Expected ApiError.invalidResponse error to be thrown.")
        } catch let error as ApiError {
            // Then
            XCTAssertEqual(error, .invalidResponse, "Send verification email should be failed due to invalid response.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testVerifyEmailSuccess() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockUserResponse3)
            
            // When
            let result = try await sut.verifyEmail(username: mockUser3.userName ?? "", code: "123")
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "Verify email response should be successful.")
            XCTAssertEqual(result?.value?.userName, mockUser3.userName, "Verify email response should have correct username.")
            XCTAssertEqual(result?.value?.isActive, false, "Verify email response should have correct isActive value (false).")
            XCTAssertNil(result?.failureReason, "Verify email should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testVerifyEmailFailWithServerResponseError() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockUserResponseWithFailureReason)
            
            // When
            let result = try await sut.verifyEmail(username: mockUser3.userName ?? "", code: "123")
            
            // Then
            XCTAssertEqual(result?.isSuccess, false, "Verify email should be failed.")
            XCTAssertNil(result?.value, "Verify email result value should be nil.")
            XCTAssertEqual(result?.failureReason, mockUserResponseWithFailureReason.failureReason, "Verify email result should be failed with failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }

    func testVerifyEmailFailWithAnyApiError() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(ApiError.httpErrorCode(401))
            
            // When
            let _ = try await sut.verifyEmail(username: mockUser3.userName ?? "", code: "123")
            XCTFail("Expected ApiError.httpErrorCode error to be thrown.")
        } catch let error as ApiError {
            // Then
            XCTAssertEqual(error, .httpErrorCode(401), "Verify email should be failed due to httpErrorCode response.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testCompleteRegisterSuccess() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockAuthResponse1)
            
            // When
            let result = try await sut.completeRegister(username: mockUser1.userName ?? "", password: mockUser1.password ?? "")
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "Complete register response should be successful.")
            XCTAssertEqual(result?.value?.token, mockAuth1.token, "Complete register should return a valid token.")
            XCTAssertNil(result?.failureReason, "Complete register should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testCompleteRegisterFailWithServerResponseError() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockAuthResponseWithFailureReason)
            
            // When
            let result = try await sut.completeRegister(username: mockUser1.userName ?? "", password: mockUser1.password ?? "")
            
            // Then
            XCTAssertEqual(result?.isSuccess, false, "Complete register should be failed.")
            XCTAssertNil(result?.value, "Complete register result value should be nil.")
            XCTAssertEqual(result?.failureReason, mockAuthResponseWithFailureReason.failureReason, "Complete register result should be failed with failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }

    func testCompleteRegisterFailWithAnyApiError() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(ApiError.invalidResponse)
            
            // When
            let _ = try await sut.completeRegister(username: mockUser1.userName ?? "", password: mockUser1.password ?? "")
            XCTFail("Expected ApiError.invalidResponse error to be thrown.")
        } catch let error as ApiError {
            // Then
            XCTAssertEqual(error, .invalidResponse, "Complete register should be failed due to invalid response.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
}
