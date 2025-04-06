//
//  BiometricsUtilTests.swift
//  TrackerParentTests
//
//  Created by Armstrong Liu on 06/04/2025.
//

import XCTest
import LocalAuthentication
@testable import TrackerParent

@MainActor
final class BiometricsUtilTests: XCTestCase {
    var sut: BiometricsUtil!
    var mockLAContext: MockLAContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        mockLAContext = MockLAContext()
        sut = BiometricsUtil(contextProvider: mockLAContext)
    }

    override func tearDownWithError() throws {
        mockLAContext = nil
        sut = nil
        
        try super.tearDownWithError()
    }
    
    func testBiometricsSuccess() async throws {
        // Given
        mockLAContext.canEvaluate = true
        mockLAContext.evalucateResult = true
        
        // When
        let result = try await sut.canUseBiometrics()
        
        // Then
        XCTAssertTrue(result, "Expected biometrics authentication to succeed")
    }
    
    func testBiometricsNotEnrolledFailure() async throws {
        // Given
        mockLAContext.canEvaluate = false
        mockLAContext.errorToThrow = LAError(.biometryNotEnrolled)
        
        // When
        do {
            let _ = try await sut.canUseBiometrics()
            XCTFail("Expected BiometryError.notEnroll to be thrown")
        } catch {
            // Then
            XCTAssertEqual(error as? BiometryError, .notEnroll, "Expected BiometryError.notEnroll to be thrown")
        }
    }
    
    func testBiometricsNotAvailableFailure() async throws {
        // Given
        mockLAContext.canEvaluate = false
        mockLAContext.errorToThrow = LAError(.biometryNotAvailable)
        
        // When
        do {
            let _ = try await sut.canUseBiometrics()
            XCTFail("Expected BiometryError.notAvailable to be thrown")
        } catch {
            // Then
            XCTAssertEqual(error as? BiometryError, .notAvailable, "Expected BiometryError.notAvailable to be thrown")
        }
    }
    
    func testBiometricsOtherErrorFailure() async throws {
        // Given
        mockLAContext.canEvaluate = false
        mockLAContext.errorToThrow = LAError(.authenticationFailed) // Give any kind LAError type
        
        // When
        do {
            let _ = try await sut.canUseBiometrics()
            XCTFail("Expected BiometryError.other to be thrown")
        } catch BiometryError.other(let error as LAError) {
            // Then
            XCTAssertEqual(error.code, .authenticationFailed, "Expected throwing out LAError.authenticationFailed error")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
