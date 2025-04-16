//
//  MockTrackService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 16/04/2025.
//

import Foundation

actor MockTrackService: TrackServiceProtocol {
    var locationResponse: LocationResponse?
    var shouldReturnError: Bool = false
    var commError: CommError?

    func setLocationResponse(_ locationResponse: LocationResponse?) {
        self.locationResponse = locationResponse
    }
    
    func setShouldReturnError(_ shouldReturnError: Bool) {
        self.shouldReturnError = shouldReturnError
    }
    
    func setCommError(_ commError: CommError?) {
        self.commError = commError
    }

    func getLocationsByDateTime(username: String, fromDateStr: String, toDateStr: String) async throws -> LocationResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let locationResponse = locationResponse, !shouldReturnError {
            return locationResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
}
