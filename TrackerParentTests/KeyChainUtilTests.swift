//
//  KeyChainUtilTests.swift
//  TrackerParentTests
//
//  Created by Armstrong Liu on 06/04/2025.
//

import XCTest
@testable import TrackerParent

final class KeyChainUtilTests: XCTestCase {
    var sut: KeyChainUtil!
    // Using unique test service name and account name to avoid affecting other keychain items
    let serviceName = "com.example.TrackerParent"
    let accountName = "testAccount"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        sut = KeyChainUtil()
        // Ensure deleting test data before every test round
        sut.delete(service: serviceName, account: accountName)
    }

    override func tearDownWithError() throws {
        // Ensure deleting test data after every test round
        sut.delete(service: serviceName, account: accountName)
        sut = nil
        
        try super.tearDownWithError()
    }
    
    func testSaveAndLoadObjectSuccess() {
        do {
            // Save the object
            // When
            let status = try sut.saveObject(service: serviceName, account: accountName, object: mockAuth1)
            
            // Then
            XCTAssertEqual(status, errSecSuccess, "Saving AuthModel should succeed")
            
            // Load the object
            // When
            let loadedObj: AuthModel? = try sut.loadObject(service: serviceName, account: accountName, type: AuthModel.self)
            // Then
            XCTAssertNotNil(loadedObj, "Loaded AuthModel should not be nil")
            XCTAssertEqual(loadedObj?.token, mockAuth1.token, "Loaded AuthModel should equal the saved object")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSaveAndLoadDataSuccess() {
        // Given
        let mockString = "Mocked string for save to the keychain"
        guard let mockData = mockString.data(using: .utf8) else {
            XCTFail("Failed to convert String to Data")
            return
        }
        
        // When
        let status = sut.save(service: serviceName, account: accountName, data: mockData)
        XCTAssertEqual(status, errSecSuccess, "Saving Data should succeed")
        
        // When
        let loadedData: Data? = sut.load(service: serviceName, account: accountName)
        
        // Then
        XCTAssertNotNil(loadedData, "Loaded Data should not be nil")
        XCTAssertEqual(loadedData, mockData, "Loaded Data should match the saved Data")
    }
    
    func testDeleteDataSuccess() {
        do {
            // When
            try sut.saveObject(service: serviceName, account: accountName, object: mockAuth1)
            let deleteStatus = sut.delete(service: serviceName, account: accountName)
            
            // Then
            XCTAssertEqual(deleteStatus, errSecSuccess, "Deleting AuthModel should succeed")
            
            // When
            let loadedObject: AuthModel? = try sut.loadObject(service: serviceName, account: accountName, type: AuthModel.self)
            
            // Then
            XCTAssertNil(loadedObject, "AuthModel should be nil after deletion")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testLoadNonExistingObject() {
        do {
            // When
            let loadedObject: AuthModel? = try sut.loadObject(service: serviceName, account: accountName, type: AuthModel.self)
            
            // Then
            XCTAssertNil(loadedObject, "AuthModel should be nil for non existing object")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
