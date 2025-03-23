//
//  MockSettingViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/23.
//

import Foundation

@MainActor
@Observable
final class MockSettingViewModel: SettingViewModelProtocol {
    var setting: SettingModel? = nil
    var updateDataState: FetchDataState = .idle
    var fetchDataState: FetchDataState = .idle
    var errMsg: String? = nil
    
    var shouldKeepLoading = false
    var shouldReturnError = false

    func fetchSetting() async {
        // Mock loading
        fetchDataState = .loading
        errMsg = nil
        
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if !shouldKeepLoading {
            if shouldReturnError {
                // Mock error
                fetchDataState = .error
                errMsg = "Mock fetching setting data error occurred"
            } else {
                // Mock loaded data
                setting = mockSetting
                fetchDataState = .done
            }
        }
    }
    
    func updateSetting() async {
        //
    }
}
