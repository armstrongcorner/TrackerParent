//
//  ApiClient.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 16/03/2025.
//

import Foundation

enum ApiError: Error, Equatable {
    case invalidUrl
    case decodingFailed(String)
    case encodingFailed(String)
    case invalidResponse
    case httpErrorCode(Int)
}

let defaultTimeout: TimeInterval = 120

protocol ApiClientProtocol: Sendable {
    func get<T: Decodable & Sendable>(urlString: String, headers: [String : String]?, timeout: TimeInterval, responseType: T.Type) async throws -> T?
    func post<T: Decodable & Sendable, R: Encodable & Sendable>(urlString: String, headers: [String : String]?, body: R?, timeout: TimeInterval, responseType: T.Type) async throws -> T?
    func delete<T: Decodable & Sendable, R: Encodable & Sendable>(urlString: String, headers: [String : String]?, body: R?, timeout: TimeInterval, responseType: T.Type) async throws -> T?
}

extension ApiClientProtocol {
    func get<T: Decodable & Sendable>(urlString: String, headers: [String : String]? = nil, timeout: TimeInterval = defaultTimeout, responseType: T.Type) async throws -> T? {
        try await get(urlString: urlString, headers: headers, timeout: timeout, responseType: responseType)
    }
    
    func post<T: Decodable & Sendable, R: Encodable & Sendable>(urlString: String, headers: [String : String]? = nil, body: R?, timeout: TimeInterval = defaultTimeout, responseType: T.Type) async throws -> T? {
        try await post(urlString: urlString, headers: headers, body: body, timeout: timeout, responseType: responseType)
    }
    
    func delete<T: Decodable & Sendable, R: Encodable & Sendable>(urlString: String, headers: [String : String]? = nil, body: R?, timeout: TimeInterval = defaultTimeout, responseType: T.Type) async throws -> T? {
        try await delete(urlString: urlString, headers: headers, body: body, timeout: timeout, responseType: responseType)
    }
}

actor ApiClient: ApiClientProtocol {
    // GET
    func get<T: Decodable & Sendable>(
        urlString: String,
        headers: [String : String]?,
        timeout: TimeInterval,
        responseType: T.Type
    ) async throws -> T? {
        return try await performRequest(
            urlString: urlString,
            method: "GET",
            headers: headers,
            timeout: timeout,
            responseType: responseType
        )
    }
    
    // POST
    func post<T: Decodable & Sendable, R: Encodable & Sendable>(
        urlString: String,
        headers: [String : String]?,
        body: R?,
        timeout: TimeInterval,
        responseType: T.Type
    ) async throws -> T? {
        var bodyData: Data?
        if let body = body {
            do {
                bodyData = try JSONEncoder().encode(body)
            } catch {
                throw ApiError.encodingFailed("Failed to encode body: \(error)")
            }
        }
        
        return try await performRequest(
            urlString: urlString,
            method: "POST",
            headers: headers,
            body: bodyData,
            timeout: timeout,
            responseType: responseType
        )
    }
    
    // DELETE
    func delete<T: Decodable & Sendable, R: Encodable & Sendable>(
        urlString: String,
        headers: [String : String]?,
        body: R?,
        timeout: TimeInterval,
        responseType: T.Type
    ) async throws -> T? {
        var bodyData: Data?
        if let body = body {
            do {
                bodyData = try JSONEncoder().encode(body)
            } catch {
                throw ApiError.encodingFailed("Failed to encode body: \(error)")
            }
        }
        
        return try await performRequest(
            urlString: urlString,
            method: "DELETE",
            headers: headers,
            body: bodyData,
            timeout: timeout,
            responseType: responseType
        )
    }
    
    private func performRequest<T: Decodable>(
        urlString: String,
        method: String,
        headers: [String : String]? = nil,
        body: Data? = nil,
        timeout: TimeInterval,
        responseType: T.Type
    ) async throws -> T? {
        guard let url = URL(string: urlString) else {
            throw ApiError.invalidUrl
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.timeoutInterval = timeout
        
        // Set customized header
        var newHeaders = getDefaultHeaders()
        newHeaders.merge(headers ?? [:]) { (_, new) in new }
        newHeaders.forEach { key, value in
            req.setValue(value, forHTTPHeaderField: key)
        }

        // Set body
        if let bodyData = body {
            req.httpBody = bodyData
        }
        
        // Make the request
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        // No response
        guard let httpResponse = resp as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }
        
        // Invalid http code
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ApiError.httpErrorCode(httpResponse.statusCode)
        }
        
        // Handle result data
        do {
            return try JSONDecoder().decode(responseType, from: data)
        } catch {
            throw ApiError.decodingFailed("Failed to decode response data: \(error)")
        }
    }
    
    private func getDefaultHeaders() -> [String : String] {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        
        let headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-app-os": "iOS",
            "x-app-version": appVersion,
        ]

        /*
         You can also add auth token here like:
         headers["Authorization"] = "Bearer \(token)"
         */
        
        return headers
    }
}
