//
//  TrackService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/19.
//

import Foundation

struct LocationRequestBody: Encodable {
    let username: String
    let startDate: String
    let endDate: String
}

protocol TrackServiceProtocol: Sendable {
    func getLocationsByDateTime(username: String, fromDateStr: String, toDateStr: String) async throws -> LocationResponse?
    func getLocationsByDateTimeWithAdmin(username: String, fromDateStr: String, toDateStr: String) async throws -> LocationResponse?
}

actor TrackService: TrackServiceProtocol, BaseServiceProtocol {
    private let apiClient: ApiClientProtocol
    
    init(apiClient: ApiClientProtocol = ApiClient()) {
        self.apiClient = apiClient
    }
    
    func getLocationsByDateTime(username: String, fromDateStr: String, toDateStr: String) async throws -> LocationResponse? {
        let defaultHeaders = try getDefaultHeaders()
        let requestBody = LocationRequestBody(username: username, startDate: fromDateStr, endDate: toDateStr)
        
        let response = try await apiClient.post(
            urlString: Endpoint.tracks.urlString,
            headers: defaultHeaders,
            body: requestBody,
            responseType: LocationResponse.self
        )
        
        return response
    }
    
    func getLocationsByDateTimeWithAdmin(username: String, fromDateStr: String, toDateStr: String) async throws -> LocationResponse? {
        let defaultHeaders = try getDefaultHeaders()
        let requestBody = LocationRequestBody(username: username, startDate: fromDateStr, endDate: toDateStr)
        
        let response = try await apiClient.post(
            urlString: Endpoint.allTracks.urlString,
            headers: defaultHeaders,
            body: requestBody,
            responseType: LocationResponse.self
        )
        
        return response
    }
}
