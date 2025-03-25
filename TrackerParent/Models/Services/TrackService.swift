//
//  TrackService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/19.
//

import Foundation

struct LocationRequestBody: Encodable {
    let startDate: String
    let endDate: String
}

protocol TrackServiceProtocol: Sendable {
//    func getLocations() async throws -> LocationResponse?
    func getLocationsByDateTime(fromDateStr: String, toDateStr: String) async throws -> LocationResponse?
}

actor TrackService: TrackServiceProtocol, BaseServiceProtocol {
    private let apiClient: ApiClientProtocol
    
    init(apiClient: ApiClientProtocol = ApiClient()) {
        self.apiClient = apiClient
    }
    
//    func getLocations() async throws -> LocationResponse? {
//        let defaultHeaders = try getDefaultHeaders()
//        
//        let response = try await apiClient.get(
//            urlString: Endpoint.tracks.urlString,
//            headers: defaultHeaders,
//            responseType: LocationResponse.self
//        )
//        
//        return response
//    }
    
    func getLocationsByDateTime(fromDateStr: String, toDateStr: String) async throws -> LocationResponse? {
        let defaultHeaders = try getDefaultHeaders()
        let requestBody = LocationRequestBody(startDate: fromDateStr, endDate: toDateStr)
        
        let response = try await apiClient.post(
            urlString: Endpoint.tracks.urlString,
            headers: defaultHeaders,
            body: requestBody,
            responseType: LocationResponse.self
        )
        
        return response
    }
}
