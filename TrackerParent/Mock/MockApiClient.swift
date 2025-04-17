//
//  MockApiClient.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 17/04/2025.
//

import Foundation

actor MockApiClient: ApiClientProtocol {
    var mockResponse: Decodable?
    var errorToThrow: Error?
    
    func setMockResponse(_ response: Decodable?) {
        self.mockResponse = response
    }
    
    func setErrorToThrow(_ error: Error?) {
        self.errorToThrow = error
    }
    
    // GET
    func get<T: Decodable & Sendable>(
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
    func post<T: Decodable & Sendable, R: Encodable & Sendable>(
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
    func delete<T: Decodable & Sendable, R: Encodable & Sendable>(
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
