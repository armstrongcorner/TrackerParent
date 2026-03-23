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
    
    var shouldKeepLoading: Bool
    var shouldReturnError: Bool
    var shouldReturnEmptyData: Bool
    
    init(
        shouldKeepLoading: Bool = false,
        shouldReturnError: Bool = false,
        shouldReturnEmptyData: Bool = false
    ) {
        self.shouldKeepLoading = shouldKeepLoading
        self.shouldReturnError = shouldReturnError
        self.shouldReturnEmptyData = shouldReturnEmptyData
    }

    func fetchTrack(username: String?, fromDate: Date, toDate: Date) async {
        // Mock loading
        fetchDataState = .loading
        errMsg = nil
        
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if !shouldKeepLoading {
            if shouldReturnError {
                // Mock error
                fetchDataState = .error
                errMsg = "Mock fetching tracks data error occurred"
            } else if shouldReturnEmptyData {
                // Mock empty data
                fetchDataState = .done
            } else {
                // Mock loaded data
                tracks.append(mockTrack)
                fetchDataState = .done
            }
        }
    }
}
