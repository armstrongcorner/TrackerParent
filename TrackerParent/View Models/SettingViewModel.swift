//
//  SettingViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/22.
//

import Foundation
import OSLog

@MainActor
protocol SettingViewModelProtocol: Sendable {
    var settingList: [SettingModel]? { get set }
    var currentSetting: SettingModel? { get set }
    var fetchDataState: FetchDataState { get }
    var updateDataState: FetchDataState { get }
    var errMsg: String? { get }
    var refreshData: Bool { get set }

    func fetchSettingList() async
    func updateCurrentSetting() async
}

@MainActor
@Observable
final class SettingViewModel: SettingViewModelProtocol {
    var settingList: [SettingModel]?
    var currentSetting: SettingModel?
    var fetchDataState: FetchDataState
    var updateDataState: FetchDataState
    var errMsg: String?
    var refreshData: Bool

    @ObservationIgnored
    private let settingService: SettingServiceProtocol
    
    @ObservationIgnored
    private let logger: Logger
    
    init(
        settingService: SettingServiceProtocol = SettingService(),
        fetchDataState: FetchDataState = .idle,
        updateDataState: FetchDataState = .idle,
        errMsg: String? = nil,
        refreshData: Bool = true
    ) {
        self.settingService = settingService
        self.fetchDataState = fetchDataState
        self.updateDataState = updateDataState
        self.errMsg = errMsg
        self.refreshData = refreshData
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        self.logger = Logger(subsystem: bundleId, category: String(describing: type(of: self)))
    }

    func fetchSettingList() async {
        do {
            fetchDataState = .loading
            errMsg = nil
            
            // Call get setting service
            guard let allSettingsResponse = try await settingService.getSettings() else {
                throw CommError.unknown
            }
            
            // Extract single setting from returned setting list
            if allSettingsResponse.isSuccess, let allSettings = allSettingsResponse.value {
                logger.debug("setting count: \(allSettings.count)")
                settingList = allSettings
                fetchDataState = .done
                refreshData = false
            } else if !allSettingsResponse.isSuccess, let failureReason = allSettingsResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleError(error)
        }
    }
    
    func updateCurrentSetting() async {
        do {
            updateDataState = .loading
            errMsg = nil
            
            // Call update setting service
            guard let settingResponse = try await settingService.updateSetting(newSetting: currentSetting ?? SettingModel()) else {
                throw CommError.unknown
            }
            
            if settingResponse.isSuccess, let newSetting = settingResponse.value {
                logger.debug("new setting: \(String(describing: newSetting))")
                // Update local current setting and setting list
                currentSetting = newSetting
                settingList = settingList?.map({ setting in
                    if setting.id == newSetting.id {
                        return newSetting
                    } else {
                        return setting
                    }
                })
                updateDataState = .done
            } else if !settingResponse.isSuccess, let failureReason = settingResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        fetchDataState = .error
        
        switch error {
        case let commError as CommError:
            errMsg = commError.errorDescription
        default:
            errMsg = error.localizedDescription
        }
    }
}
