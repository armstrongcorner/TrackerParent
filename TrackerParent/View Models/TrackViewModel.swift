//
//  TrackViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/19.
//

import Foundation
import OSLog

@MainActor
protocol TrackViewModelProtocol: Sendable {
    var tracks: [[LocationModel]] { get }
    
    func fetchTrack() async
}

@MainActor
@Observable
final class TrackViewModel: TrackViewModelProtocol {
    var tracks: [[LocationModel]] = []
    
    @ObservationIgnored
    private let trackService: TrackServiceProtocol
    
    @ObservationIgnored
    private let logger: Logger
    
    init(trackService: TrackServiceProtocol = TrackService()) {
        self.trackService = trackService
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        self.logger = Logger(subsystem: bundleId, category: String(describing: type(of: self)))
    }
    
    func fetchTrack() async {
        do {
            // Call get track list service
            guard let locationResponse = try await trackService.getLocations() else {
                throw CommError.unknown
            }
            
            // Build tracks from retrieved locations
            if locationResponse.isSuccess, let locationList = locationResponse.value {
                logger.debug("--- location count: \(locationList.count)")
                
                var lastLocation: LocationModel? = nil
                var newTrack: [LocationModel] = []
                locationList.forEach { locationModel in
                    if lastLocation != nil && DateUtil.shared.minutesBetween(from: lastLocation?.createdDateTime ?? "", to: locationModel.createdDateTime) > 30 {
                        tracks.append(newTrack)
                        newTrack = []
                    }
                    newTrack.append(locationModel)
                    
                    lastLocation = locationModel
                }
                if !newTrack.isEmpty {
                    tracks.append(newTrack)
                }
            }
            
            logger.debug("--- track count: \(self.tracks.count)")
        } catch {
            //
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
}
