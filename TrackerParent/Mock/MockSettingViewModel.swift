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
    var fetchDataState: FetchDataState = .idle
    var addDataState: FetchDataState = .idle
    var updateDataState: FetchDataState = .idle
    var deleteDataState: FetchDataState = .idle
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
    
    func addNewSetting() async {
        // Mock loading
        addDataState = .loading
        errMsg = nil
        
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if shouldReturnError {
            // Mock error
            addDataState = .error
            errMsg = "Mock adding setting data error occurred"
        } else {
            // Mock added data
            let addedSetting = SettingModel(
                id: 3,
                userName: "test_username",
                collectionFrequency: 10,
                pushFrequency: 10,
                distanceFilter: 100,
                startTime: "14:00:00",
                endTime: "18:00:00",
                accuracy: "Medium"
            )
            settingList?.append(addedSetting)
            addDataState = .done
        }
    }
    
    func updateCurrentSetting() async {
        // Mock loading
        updateDataState = .loading
        errMsg = nil
        currentSetting = mockSetting1
        
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if shouldReturnError {
            // Mock error
            updateDataState = .error
            errMsg = "Mock updating setting data error occurred"
        } else {
            // Mock updated data
            var updatedSetting = mockSetting1
            updatedSetting.distanceFilter = 100
            updatedSetting.startTime = "14:00:00"
            updatedSetting.endTime = "18:00:00"
            updatedSetting.accuracy = "Low"
            
            currentSetting = updatedSetting
            settingList?.replace([mockSetting1], with: [currentSetting!])
            updateDataState = .done
        }
    }
    
    func deleteCurrentSetting() async {
        // Mock loading
        deleteDataState = .loading
        errMsg = nil
        currentSetting = mockSetting1
        
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if shouldReturnError {
            deleteDataState = .error
            errMsg = "Mock deleting setting data error occurred"
        } else {
            deleteDataState = .done
        }
    }
}
