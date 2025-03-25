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

    func fetchTrack(fromDate: Date, toDate: Date) async
    func logout()
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
    private let logger: Logger
    
    init(
        trackService: TrackServiceProtocol = TrackService(),
        fetchDataState: FetchDataState = .idle,
        errMsg: String? = nil
    ) {
        self.trackService = trackService
        self.fetchDataState = fetchDataState
        self.errMsg = errMsg
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        self.logger = Logger(subsystem: bundleId, category: String(describing: type(of: self)))
    }
    
    func fetchTrack(fromDate: Date, toDate: Date) async {
        do {
            tracks = []
            fetchDataState = .loading
            errMsg = nil
            
            // Call get track list service
            let fromDate = DateUtil.shared.startOfTheDate(date: fromDate)
            let endDate = DateUtil.shared.endOfTheDate(date: toDate)
            
            guard let locationResponse = try await trackService.getLocationsByDateTime(
                fromDateStr: DateUtil.shared.convertToISO8601Str(date: fromDate),
                toDateStr: DateUtil.shared.convertToISO8601Str(date: endDate)) else {
                throw CommError.unknown
            }
            
            // Build tracks from retrieved locations
            if locationResponse.isSuccess, let locationList = locationResponse.value {
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
                
                fetchDataState = .done
                
                logger.debug("--- track count: \(self.tracks.count)")
            } else if !locationResponse.isSuccess, let failureReason = locationResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleError(error)
        }
    }
    
    func logout() {
        let service = Bundle.main.bundleIdentifier ?? ""
        let account = UserDefaults.standard.string(forKey: "username") ?? ""
        
        // Clear cached username
        UserDefaults.standard.set(nil, forKey: "username")
        
        // Clear cached authModel in keychain
        KeyChainUtil.shared.delete(service: service, account: account)
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
