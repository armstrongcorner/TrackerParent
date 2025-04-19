//
//  ApiClientTests.swift
//  TrackerParentTests
//
//  Created by Armstrong Liu on 19/04/2025.
//

import XCTest
@testable import TrackerParent

final class ApiClientTests: XCTestCase {
    var sut: ApiClient!
    var mockUrlSession: URLSession!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockUrlSession = URLSession(configuration: config)
        sut = ApiClient(urlSession: mockUrlSession)
    }

    override func tearDownWithError() throws {
        mockUrlSession = nil
        sut = nil
        MockURLProtocol.requestHandler = nil
        
        try super.tearDownWithError()
    }
    
    func testGetRequestSuccess() async {
        do {
            // Given
            let mockReturnData = try JSONEncoder().encode(mockAuthResponse1)
            
            MockURLProtocol.requestHandler = { request in
                let resp = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type":"application/json"]
                )!
                return (resp, mockReturnData)
            }
            
            // When
            let result = try await sut.get(urlString: "https://example.com", responseType: AuthResponse.self)
            
            // Then
            XCTAssertEqual(result?.isSuccess, true, "Get request should be successful.")
            XCTAssertEqual(result?.value?.token, mockAuth1.token, "Get request should return correct token.")
            XCTAssertNil(result?.failureReason, "Get request should return no failureReason.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testGetRequestThrowsInvalidUrlError() async throws {
        // Given
        let cleanConfig = URLSessionConfiguration.ephemeral
        cleanConfig.protocolClasses = []
        let cleanSession = URLSession(configuration: cleanConfig)
        sut = ApiClient(urlSession: cleanSession)
        
        do {
            // When
            _ = try await sut.get(
                urlString: "not a valid url",
                responseType: String.self
            )
            XCTFail("Expected ApiError.invalidUrl to be thrown")
        } catch let error as ApiError {
            // Then
            XCTAssertEqual(error, .invalidUrl, "Get request failed with invalid url error")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testPostRequestThrowsEncodingRequestBodyError() async {
        // Given
        struct FailingEncodable: Encodable {
            // Mock encode func when use JSONEncoder().encode
            func encode(to encoder: Encoder) throws {
                throw NSError(domain: "TestDomain", code: 1, userInfo: nil)
            }
        }
        
        do {
            // When
            _ = try await sut.post(
                urlString: "https://example.com",
                body: FailingEncodable(),
                responseType: String.self
            )
            XCTFail("Expected ApiError.encodingFailed to be thrown")
        } catch let error as ApiError {
            // Then
            if case .encodingFailed(let errMsg) = error {
                XCTAssert(errMsg.contains("Failed to encode body"), "Expected encodingFailed error with proper message")
            } else {
                XCTFail("Unexpected ApiError case: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetRequestThrowsDecodingResponseError() async {
        do {
            // Given
            let mockBadReturnData = "Invalid JSON".data(using: .utf8)!
            
            MockURLProtocol.requestHandler = { request in
                let resp = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type":"application/json"]
                )!
                return (resp, mockBadReturnData)
            }
            
            // When
            _ = try await sut.get(urlString: "https://example.com", responseType: AuthResponse.self)
            XCTFail("Expected ApiError.decodingFailed to be thrown")
        } catch let error as ApiError {
            // Then
            if case .decodingFailed(let errMsg) = error {
                XCTAssert(errMsg.contains("Failed to decode response data"), "Get request failed to decode response data.")
            } else {
                XCTFail("Unexpected ApiError case: \(error).")
            }
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
    
    func testGetRequestThrowsInvalidResponse() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            let response = URLResponse(
                url: request.url!,
                mimeType: nil,
                expectedContentLength: 0,
                textEncodingName: nil
            )
            return (response, nil)
        }

        do {
            // When
            _ = try await sut.get(urlString: "https://example.com", responseType: String.self)
            XCTFail("Expected ApiError.invalidResponse to be thrown")
        } catch let error as ApiError {
            XCTAssertEqual(error, .invalidResponse, "Get request failed with invalid response error.")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testGetRequestThrowsHttpErrorCode() async {
        do {
            // Given
            MockURLProtocol.requestHandler = { request in
                let resp = HTTPURLResponse(
                    url: request.url!,
                    statusCode: 404,
                    httpVersion: nil,
                    headerFields: nil
                )!
                return (resp, nil)
            }
            
            // When
            _ = try await sut.get(urlString: "https://example.com", responseType: String.self)
            XCTFail("Expected httpErrorCode: 404")
        } catch let error as ApiError {
            // Then
            XCTAssertEqual(error, .httpErrorCode(404), "Get request should be failed with 404 http status code error.")
        } catch {
            XCTFail("Unexpected error: \(error).")
        }
    }
}
