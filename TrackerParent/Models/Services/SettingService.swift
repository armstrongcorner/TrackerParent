//
//  SettingService.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/22.
//

import Foundation

protocol SettingServiceProtocol: Sendable {
    func getSettings() async throws -> AllSettingsResponse?
    func addSetting(newSetting: SettingModel) async throws -> SettingResponse?
    func updateSetting(newSetting: SettingModel) async throws -> SettingResponse?
    func deleteSetting(newSetting: SettingModel) async throws -> DeleteSettingResponse?
}

actor SettingService: SettingServiceProtocol, BaseServiceProtocol {
    private let apiClient: ApiClientProtocol
    
    init(apiClient: ApiClientProtocol = ApiClient()) {
        self.apiClient = apiClient
    }
    
    func getSettings() async throws -> AllSettingsResponse? {
        let defaultHeaders = try getDefaultHeaders()
        
        let response = try await apiClient.get(
            urlString: Endpoint.setting.urlString,
            headers: defaultHeaders,
            responseType: AllSettingsResponse.self
        )
        
        return response
    }
    
    func addSetting(newSetting: SettingModel) async throws -> SettingResponse? {
        let defaultHeaders = try getDefaultHeaders()
        
        let response = try await apiClient.post(
            urlString: Endpoint.addSetting.urlString,
            headers: defaultHeaders,
            body: newSetting,
            responseType: SettingResponse.self
        )
        
        return response
    }
    
    func updateSetting(newSetting: SettingModel) async throws -> SettingResponse? {
        let defaultHeaders = try getDefaultHeaders()
        
        let response = try await apiClient.post(
            urlString: Endpoint.updateSetting.urlString,
            headers: defaultHeaders,
            body: newSetting,
            responseType: SettingResponse.self
        )
        
        return response
    }
    
    func deleteSetting(newSetting: SettingModel) async throws -> DeleteSettingResponse? {
        let defaultHeaders = try getDefaultHeaders()
        
        let response = try await apiClient.delete(
            urlString: Endpoint.deleteSetting.urlString,
            headers: defaultHeaders,
            body: newSetting,
            responseType: DeleteSettingResponse.self
        )
        
        return response
    }
}
