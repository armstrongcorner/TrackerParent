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
    var settingList: [SettingModel]? = nil
    var currentSetting: SettingModel? = nil
    var updateDataState: FetchDataState = .idle
    var fetchDataState: FetchDataState = .idle
    var errMsg: String? = nil
    var refreshData: Bool = true
    
    var shouldKeepLoading = false
    var shouldReturnError = false

    func fetchSettingList() async {
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
                settingList = [mockSetting1, mockSetting2]
                fetchDataState = .done
            }
        }
    }
    
    func updateCurrentSetting() async {
        //
    }
}
