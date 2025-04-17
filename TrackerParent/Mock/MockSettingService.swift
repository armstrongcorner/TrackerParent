//
//  MockSettingService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 17/04/2025.
//

import Foundation

actor MockSettingService: SettingServiceProtocol {
    var settingResponse: SettingResponse?
    var allSettingsResponse: AllSettingsResponse?
    var deleteSettingResponse: DeleteSettingResponse?
    var shouldReturnError: Bool = false
    var commError: CommError?

    func setSettingResponse(_ settingResponse: SettingResponse?) {
        self.settingResponse = settingResponse
    }
    
    func setAllSettingsResponse(_ allSettingsResponse: AllSettingsResponse?) {
        self.allSettingsResponse = allSettingsResponse
    }
    
    func setDeleteSettingResponse(_ deleteSettingResponse: DeleteSettingResponse?) {
        self.deleteSettingResponse = deleteSettingResponse
    }
    
    func setShouldReturnError(_ shouldReturnError: Bool) {
        self.shouldReturnError = shouldReturnError
    }
    
    func setCommError(_ commError: CommError?) {
        self.commError = commError
    }

    func getSettings() async throws -> AllSettingsResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let allSettingsResponse = allSettingsResponse, !shouldReturnError {
            return allSettingsResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
    
    func addSetting(newSetting: SettingModel) async throws -> SettingResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let settingResponse = settingResponse, !shouldReturnError {
            return settingResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
    
    func updateSetting(newSetting: SettingModel) async throws -> SettingResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let settingResponse = settingResponse, !shouldReturnError {
            return settingResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
    
    func deleteSetting(newSetting: SettingModel) async throws -> DeleteSettingResponse? {
        // Mock access network time
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if let deleteSettingResponse = deleteSettingResponse, !shouldReturnError {
            return deleteSettingResponse
        } else if let commError = commError {
            throw commError
        } else {
            throw CommError.unknown
        }
    }
}
