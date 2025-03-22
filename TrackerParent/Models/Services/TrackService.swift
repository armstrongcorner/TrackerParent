//
//  TrackService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/19.
//

import Foundation

protocol TrackServiceProtocol: Sendable {
    func getLocations() async throws -> LocationResponse?
}

actor TrackService: TrackServiceProtocol, BaseServiceProtocol {
    private let apiClient: ApiClientProtocol
    
    init(apiClient: ApiClientProtocol = ApiClient()) {
        self.apiClient = apiClient
    }
    
    func getLocations() async throws -> LocationResponse? {
        let defaultHeaders = try getDefaultHeaders()
        
        let response = try await apiClient.get(
            urlString: Endpoint.tracks.urlString,
            headers: defaultHeaders,
            responseType: LocationResponse.self
        )
        
        return response
    }
}
