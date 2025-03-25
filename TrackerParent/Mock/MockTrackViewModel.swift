//
//  MockTrackViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/22.
//

import Foundation

@MainActor
@Observable
final class MockTrackViewModel: TrackViewModelProtocol {
    var tracks: [[LocationModel]] = []
    var fetchDataState: FetchDataState = .idle
    var errMsg: String? = nil
    
    var shouldKeepLoading = false
    var shouldReturnError = false

    func fetchTrack(fromDate: Date, toDate: Date) async {
        // Mock loading
        fetchDataState = .loading
        errMsg = nil
        
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if !shouldKeepLoading {
            if shouldReturnError {
                // Mock error
                fetchDataState = .error
                errMsg = "Mock fetching tracks data error occurred"
            } else {
                // Mock loaded data
                tracks.append(mockTrack)
                fetchDataState = .done
            }
        }
    }
    
    func logout() {
        
    }
}
