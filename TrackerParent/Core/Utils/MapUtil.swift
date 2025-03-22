//
//  MapUtil.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/21.
//

import Foundation
import MapKit

struct MapUtil {
    static let shared = MapUtil()
    
    private init() {}
    
    // Calculate a MKCoordinateRegion regarding the track
    func regionForCoordinates(from track: [LocationModel]) -> MKCoordinateRegion {
        // Extract the all locations in the track
        let coordinates = track.compactMap { location -> CLLocationCoordinate2D? in
            if let lat = Double(location.latitude),
               let lon = Double(location.longitude) {
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            return nil
        }
        
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            )
        }
        
        var minLat = coordinates.first!.latitude
        var maxLat = coordinates.first!.latitude
        var minLon = coordinates.first!.longitude
        var maxLon = coordinates.first!.longitude
        
        for coord in coordinates {
            minLat = min(minLat, coord.latitude)
            maxLat = max(maxLat, coord.latitude)
            minLon = min(minLon, coord.longitude)
            maxLon = max(maxLon, coord.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        // 1.2 for the margin of the region
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.2,
            longitudeDelta: (maxLon - minLon) * 1.2
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}
