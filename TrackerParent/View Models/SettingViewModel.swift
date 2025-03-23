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
    var setting: SettingModel? { get set }
    var fetchDataState: FetchDataState { get }
    var updateDataState: FetchDataState { get }
    var errMsg: String? { get }

    func fetchSetting() async
    func updateSetting() async
}

@MainActor
@Observable
final class SettingViewModel: SettingViewModelProtocol {
//    var startTime: String
//    var endTime: String
//    var distanceFilter: Int
//    var accuracy: String
    var setting: SettingModel?
    var fetchDataState: FetchDataState
    var updateDataState: FetchDataState
    var errMsg: String?

    @ObservationIgnored
    private let settingService: SettingServiceProtocol
    
    @ObservationIgnored
    private let logger: Logger
    
    init(
        settingService: SettingServiceProtocol = SettingService(),
        fetchDataState: FetchDataState = .idle,
        updateDataState: FetchDataState = .idle,
        errMsg: String? = nil
    ) {
        self.settingService = settingService
        self.fetchDataState = fetchDataState
        self.updateDataState = updateDataState
        self.errMsg = errMsg
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        self.logger = Logger(subsystem: bundleId, category: String(describing: type(of: self)))
    }

    func fetchSetting() async {
        do {
            fetchDataState = .loading
            errMsg = nil
            
            // Call get setting service
            guard let allSettingsResponse = try await settingService.getSettings() else {
                throw CommError.unknown
            }
            
            // Extract single setting from returned setting list
            if allSettingsResponse.isSuccess, let settingList = allSettingsResponse.value {
                logger.debug("setting count: \(settingList.count)")
                guard settingList.count > 0 else {
                    throw CommError.noData
                }
                
                setting = settingList.first!
                fetchDataState = .done
            } else if !allSettingsResponse.isSuccess, let failureReason = allSettingsResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleError(error)
        }
    }
    
    func updateSetting() async {
        do {
            updateDataState = .loading
            errMsg = nil
            
            // Call update setting service
            guard let settingResponse = try await settingService.updateSetting(newSetting: setting ?? SettingModel()) else {
                throw CommError.unknown
            }
            
            if settingResponse.isSuccess, let newSetting = settingResponse.value {
                logger.debug("new setting: \(String(describing: newSetting))")
                
                setting = newSetting
                fetchDataState = .done
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
