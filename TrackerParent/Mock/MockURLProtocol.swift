//
//  MockURLProtocol.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 19/04/2025.
//

import Foundation

class MockURLProtocol: URLProtocol {
//    static var requestHandler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data?))?
    static var requestHandler: (@Sendable (URLRequest) throws -> (URLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("MockURLProtocol needs a handler to be set")
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
