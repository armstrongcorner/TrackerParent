//
//  MockApiClient.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 17/04/2025.
//

import Foundation
import MTNetworkManager

actor MockMTApiClient: MTApiClientProtocol {
    var mockResponse: Codable?
    var errorToThrow: Error?
    
    func setMockResponse(_ response: Codable?) {
        self.mockResponse = response
    }
    
    func setErrorToThrow(_ error: Error?) {
        self.errorToThrow = error
    }
    
    // GET
    func get<T: Codable & Sendable>(
        urlString: String,
        headers: [String : String]?,
        timeout: TimeInterval,
        responseType: T.Type
    ) async throws -> T? {
        if let errorToThrow = errorToThrow {
            throw errorToThrow
        }
        
        return mockResponse as? T
    }
    
    // POST
    func post<T: Codable & Sendable, R: Codable & Sendable>(
        urlString: String,
        headers: [String : String]?,
        body: R?,
        timeout: TimeInterval,
        responseType: T.Type
    ) async throws -> T? {
        if let errorToThrow = errorToThrow {
            throw errorToThrow
        }
        
        return mockResponse as? T
    }
    
    // DELETE
    func delete<T: Codable & Sendable, R: Codable & Sendable>(
        urlString: String,
        headers: [String : String]?,
        body: R?,
        timeout: TimeInterval,
        responseType: T.Type
    ) async throws -> T? {
        if let errorToThrow = errorToThrow {
            throw errorToThrow
        }
        
        return mockResponse as? T
    }
}
