//
//  TrackServiceTests.swift
//  TrackerParentTests
//
//  Created by Armstrong Liu on 18/04/2025.
//

import XCTest
@testable import TrackerParent

final class TrackServiceTests: XCTestCase {
    var sut: TrackService!
    var mockApiClient: MockApiClient!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockApiClient = MockApiClient()
        sut = TrackService(apiClient: mockApiClient)
    }

    override func tearDownWithError() throws {
        mockApiClient = nil
        sut = nil
        
        try super.tearDownWithError()
    }

    func testGetLocationsByDateTimeSuccess() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockLocationResponse)
            
            // When
            let result = try await sut.getLocationsByDateTime(username: mockUser1.userName ?? "", fromDateStr: DateUtil.shared.convertToISO8601Str(date: .now), toDateStr: DateUtil.shared.convertToISO8601Str(date: .now))
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "Get locations should be successful.")
            XCTAssertEqual(result?.value?.count, mockTrack.count, "Get locations should return the correct number of locations.")
            XCTAssertNil(result?.failureReason, "Get locations should be no failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testGetLocationsByDateTimeFailWithServerResponseError() async {
        do {
            // Given
            await mockApiClient.setMockResponse(mockLocationResponseWithFailureReason)
            
            // When
            let result = try await sut.getLocationsByDateTime(username: mockUser1.userName ?? "", fromDateStr: DateUtil.shared.convertToISO8601Str(date: .now), toDateStr: DateUtil.shared.convertToISO8601Str(date: .now))
            
            // Then
            XCTAssertEqual(result?.isSuccess, false, "Get locations should be failed.")
            XCTAssertNil(result?.value, "Get locations result value should be nil.")
            XCTAssertEqual(result?.failureReason, mockLocationResponseWithFailureReason.failureReason, "Get locations result should be failed with failure reason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }

    func testGetLocationsByDateTimeFailWithEncodingError() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(ApiError.encodingFailed("Failed to encode location request body"))
            
            // When
            let _ = try await sut.getLocationsByDateTime(username: mockUser1.userName ?? "", fromDateStr: DateUtil.shared.convertToISO8601Str(date: .now), toDateStr: DateUtil.shared.convertToISO8601Str(date: .now))
            XCTFail("Expected ApiError.encodingFailed error to be thrown.")
        } catch let error as ApiError {
            // Then
            XCTAssertEqual(error, .encodingFailed("Failed to encode location request body"), "Get locations should be failed due to request body encoded incorrectly.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testGetLocationsByDateTimeFailWithDecodingError() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(ApiError.decodingFailed("Failed to decode location response"))
            
            // When
            let _ = try await sut.getLocationsByDateTime(username: mockUser1.userName ?? "", fromDateStr: DateUtil.shared.convertToISO8601Str(date: .now), toDateStr: DateUtil.shared.convertToISO8601Str(date: .now))
            XCTFail("Expected ApiError.decodingFailed error to be thrown.")
        } catch let error as ApiError {
            // Then
            XCTAssertEqual(error, .decodingFailed("Failed to decode location response"), "Get locations should be failed due to response decoded incorrectly.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }

    func testGetLocationsByDateTimeFailWithInvalidUrl() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(ApiError.invalidUrl)
            
            // When
            let _ = try await sut.getLocationsByDateTime(username: mockUser1.userName ?? "", fromDateStr: DateUtil.shared.convertToISO8601Str(date: .now), toDateStr: DateUtil.shared.convertToISO8601Str(date: .now))
            XCTFail("Expected ApiError.invalidUrl error to be thrown.")
        } catch let error as ApiError {
            // Then
            XCTAssertEqual(error, .invalidUrl, "Get locations should be failed due to invalid url.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testGetLocationsByDateTimeFailWithInvalidResponse() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(ApiError.invalidResponse)
            
            // When
            let _ = try await sut.getLocationsByDateTime(username: mockUser1.userName ?? "", fromDateStr: DateUtil.shared.convertToISO8601Str(date: .now), toDateStr: DateUtil.shared.convertToISO8601Str(date: .now))
            XCTFail("Expected ApiError.invalidResponse error to be thrown.")
        } catch let error as ApiError {
            // Then
            XCTAssertEqual(error, .invalidResponse, "Get locations should be failed due to invalid response.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testGetLocationsByDateTimeFailWithHttpErrorCode() async {
        do {
            // Given
            await mockApiClient.setErrorToThrow(ApiError.httpErrorCode(401))
            
            // When
            let _ = try await sut.getLocationsByDateTime(username: mockUser1.userName ?? "", fromDateStr: DateUtil.shared.convertToISO8601Str(date: .now), toDateStr: DateUtil.shared.convertToISO8601Str(date: .now))
            XCTFail("Expected ApiError.httpErrorCode error to be thrown.")
        } catch let error as ApiError {
            // Then
            XCTAssertEqual(error, .httpErrorCode(401), "Get locations should be failed due to http error code (401).")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
}
