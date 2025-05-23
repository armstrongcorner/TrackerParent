//
//  TrackViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/19.
//

import Foundation
import OSLog

enum FetchDataState {
    case done
    case loading
    case error
    case idle
}

@MainActor
protocol TrackViewModelProtocol: Sendable {
    var tracks: [[LocationModel]] { get }
    var fetchDataState: FetchDataState { get }
    var errMsg: String? { get }

    func fetchTrack(username: String?, fromDate: Date, toDate: Date) async
}

@MainActor
@Observable
final class TrackViewModel: TrackViewModelProtocol {
    var tracks: [[LocationModel]] = []
    var fetchDataState: FetchDataState
    var errMsg: String?

    @ObservationIgnored
    private let trackService: TrackServiceProtocol
    @ObservationIgnored
    private let keyChainUtil: KeyChainUtilProtocol
    @ObservationIgnored
    private let userDefaults: UserDefaults

    @ObservationIgnored
    private let logger: Logger
    
    init(
        trackService: TrackServiceProtocol = TrackService(),
        keyChainUtil: KeyChainUtilProtocol = KeyChainUtil.shared,
        userDefaults: UserDefaults = .standard,
        fetchDataState: FetchDataState = .idle,
        errMsg: String? = nil
    ) {
        self.trackService = trackService
        self.keyChainUtil = keyChainUtil
        self.userDefaults = userDefaults
        self.fetchDataState = fetchDataState
        self.errMsg = errMsg
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        self.logger = Logger(subsystem: bundleId, category: String(describing: type(of: self)))
    }
    
    func fetchTrack(username: String?, fromDate: Date, toDate: Date) async {
        do {
            tracks = []
            fetchDataState = .loading
            errMsg = nil
            
            // Load auth model from keychain
            let loadedAuthModel = try keyChainUtil.loadObject(account: userDefaults.string(forKey: "username") ?? "", type: AuthModel.self)
            
            // Call get track list service
            let theUsername = username ?? userDefaults.string(forKey: "username") ?? ""
            let fromDate = DateUtil.shared.startOfTheDate(date: fromDate)
            let endDate = DateUtil.shared.endOfTheDate(date: toDate)
            
            var locationResponse: LocationResponse?
            if loadedAuthModel?.userRole == "User" {
                guard let locationResp = try await trackService.getLocationsByDateTime(
                    username: theUsername,
                    fromDateStr: DateUtil.shared.convertToISO8601Str(date: fromDate),
                    toDateStr: DateUtil.shared.convertToISO8601Str(date: endDate)) else {
                    throw CommError.unknown
                }
                locationResponse = locationResp
            } else if loadedAuthModel?.userRole == "Administrator" {
                guard let locationResp = try await trackService.getLocationsByDateTimeWithAdmin(
                    username: theUsername,
                    fromDateStr: DateUtil.shared.convertToISO8601Str(date: fromDate),
                    toDateStr: DateUtil.shared.convertToISO8601Str(date: endDate)) else {
                    throw CommError.unknown
                }
                locationResponse = locationResp
            }
            
            // Build tracks from retrieved locations
            if let locationResponse = locationResponse, locationResponse.isSuccess, let locationList = locationResponse.value {
                logger.debug("--- location count: \(locationList.count)")
                
                var lastLocation: LocationModel? = nil
                var newTrack: [LocationModel] = []
                locationList.forEach { locationModel in
                    if lastLocation != nil && DateUtil.shared.minutesBetween(from: lastLocation?.dateTimeOcurred ?? "", to: locationModel.dateTimeOcurred) > 30 {
                        tracks.append(newTrack)
                        newTrack = []
                    }
                    newTrack.append(locationModel)
                    
                    lastLocation = locationModel
                }
                if !newTrack.isEmpty {
                    tracks.append(newTrack)
                }
                
                // Sort the tracks by descending dateTimeOcurred of the first location model
                tracks.sort { trackA, trackB in
                    guard let firstA = trackA.first, let firstB = trackB.first else {
                        return false
                    }
                    return firstA.dateTimeOcurred > firstB.dateTimeOcurred
                }
                
                fetchDataState = .done
                
                logger.debug("--- track count: \(self.tracks.count)")
            } else if let locationResponse = locationResponse, !locationResponse.isSuccess, let failureReason = locationResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.fetchDataState = .error
        }
        
        switch error {
        case let commError as CommError:
            errMsg = commError.errorDescription
        default:
            errMsg = error.localizedDescription
        }
    }
}
