//
//  SettingViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/22.
//

import Foundation
import OSLog

enum SettingType {
    case fetch
    case add
    case update
    case delete
}

@MainActor
protocol SettingViewModelProtocol: Sendable {
    var settingList: [SettingModel]? { get set }
    var currentSetting: SettingModel? { get set }
    var fetchDataState: FetchDataState { get }
    var addDataState: FetchDataState { get }
    var updateDataState: FetchDataState { get }
    var deleteDataState: FetchDataState { get }
    var errMsg: String? { get }
    var refreshData: Bool { get set }

    func fetchSettingList() async
    func addNewSetting() async
    func updateCurrentSetting() async
    func deleteCurrentSetting() async
}

@MainActor
@Observable
final class SettingViewModel: SettingViewModelProtocol {
    var settingList: [SettingModel]?
    var currentSetting: SettingModel?
    var fetchDataState: FetchDataState
    var addDataState: FetchDataState
    var updateDataState: FetchDataState
    var deleteDataState: FetchDataState
    var errMsg: String?
    var refreshData: Bool

    @ObservationIgnored
    private let settingService: SettingServiceProtocol
    
    @ObservationIgnored
    private let logger: Logger
    
    init(
        settingService: SettingServiceProtocol = SettingService(),
        fetchDataState: FetchDataState = .idle,
        addDataState: FetchDataState = .idle,
        updateDataState: FetchDataState = .idle,
        deleteDataState: FetchDataState = .idle,
        errMsg: String? = nil,
        refreshData: Bool = true
    ) {
        self.settingService = settingService
        self.fetchDataState = fetchDataState
        self.addDataState = addDataState
        self.updateDataState = updateDataState
        self.deleteDataState = deleteDataState
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
            handleError(error, type: .fetch)
        }
    }
    
    func addNewSetting() async {
        do {
            addDataState = .loading
            errMsg = nil
            
            // Call add setting service
            guard let settingResponse = try await settingService.addSetting(newSetting: currentSetting ?? SettingModel()) else {
                throw CommError.unknown
            }
            
            if settingResponse.isSuccess, let newSetting = settingResponse.value {
                logger.debug("new setting: \(String(describing: newSetting))")
                
                if settingList == nil {
                    settingList = []
                }
                settingList?.append(newSetting)
                addDataState = .done
//                refreshData = true
            } else if !settingResponse.isSuccess, let failureReason = settingResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleError(error, type: .add)
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
            handleError(error, type: .update)
        }
    }
    
    func deleteCurrentSetting() async {
        do {
            deleteDataState = .loading
            errMsg = nil
            
            // Call delete setting service
            guard let deleteSettingResponse = try await settingService.deleteSetting(newSetting: currentSetting ?? SettingModel()) else {
                throw CommError.unknown
            }
            
            if deleteSettingResponse.isSuccess, let result = deleteSettingResponse.value {
                logger.debug("delete setting result: \(result)")
                
                if result {
                    deleteDataState = .done
                } else {
                    throw CommError.unknown
                }
            } else if !deleteSettingResponse.isSuccess, let failureReason = deleteSettingResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleError(error, type: .delete)
        }
    }
    
    private func handleError(_ error: Error, type: SettingType) {
        switch type {
        case .fetch:
            fetchDataState = .error
        case .add:
            addDataState = .error
        case .update:
            updateDataState = .error
        case .delete:
            deleteDataState = .error
        }
        
        switch error {
        case let commError as CommError:
            errMsg = commError.errorDescription
        default:
            errMsg = error.localizedDescription
        }
    }
}
