//
//  TrackDetailScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/20.
//

import SwiftUI
import MapKit
import SwiftfulRouting

struct TrackDetailScreen: View {
    let router: AnyRouter
    let track: [LocationModel]
    
    @State private var position: MapCameraPosition
    @State private var mapStyle: MapStyle = .standard
    @State private var mapStyleLabel: String = "Standard"
    @State private var mapThemeColor: Color = .gray
    @State private var mapAnnotationColor: Color = .black
    @State private var mapTextColor: Color = .white
    @State private var mapLineColor: Color = .gray
    
    init(router: AnyRouter, track: [LocationModel]) {
        self.router = router
        self.track = track
        
        // Calculate the original region to cover all locations of the track
//        self.position = .region(MapUtil.shared.regionForCoordinates(from: track))
        self.position = .automatic
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(position: $position) {
//                ForEach(track, id: \.self) { locationModel in
                ForEach(0..<track.count, id: \.self) { i in
                    let locationModel = track[i]
                    let coordinate = CLLocationCoordinate2D(
                        latitude: Double(locationModel.latitude) ?? 0,
                        longitude: Double(locationModel.longitude) ?? 0
                    )
                    
                    Annotation("\(locationModel.id)", coordinate: coordinate) {
                        Button {
                            print("coordinate: \(coordinate)")
                        } label: {
//                            var iconName = "smallcircle.filled.circle.fill"
//                            if i == 0 {
//                                iconName = "figure.walk.circle"
//                            }
                            
                            /// Direction
                            /// 0 - North;
                            /// -1 - No direction captured
                            /// x - Angle degree by clockwise from North
                            let directionValue = Double(locationModel.direction ?? "0") ?? 0
//                            Image(systemName: directionValue > 0 ? "location.north.fill" : "smallcircle.filled.circle.fill")
                            Image(systemName: i == 0 ? "figure.walk.motion" : i == track.count - 1 ? "flag.pattern.checkered" : directionValue > 0 ? "location.north.fill" : "smallcircle.filled.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: i == 0 || i == track.count - 1 ? 30 : 15)
                                .rotationEffect(Angle(degrees: i == 0 || i == track.count - 1 ? 0 : directionValue))
                                .foregroundStyle(mapAnnotationColor)
                        }
                        .buttonStyle(.plain)
                    }
//                    .annotationTitles(.hidden)
                }
                
                let theRoute: [CLLocationCoordinate2D] = track.map { locationModel in
                    CLLocationCoordinate2D(
                        latitude: Double(locationModel.latitude) ?? 0,
                        longitude: Double(locationModel.longitude) ?? 0
                    )
                }
                MapPolyline(coordinates: theRoute)
                    .stroke(mapLineColor, lineWidth: 5)
//                    .stroke(mapLineColor, style: .init(lineWidth: 3, dash: [5]))
            }
            .mapStyle(mapStyle)
            
            // Top layer
            ZStack(alignment: .leading) {
                // Map style selection
                HStack {
                    Spacer()
                    
                    Menu {
                        Button("Standard") {
                            mapStyle = .standard(elevation: .realistic)
                            mapStyleLabel = "Standard"
                            mapThemeColor = .gray
                            mapAnnotationColor = .black
                            mapTextColor = .white
                            mapLineColor = .gray
                        }
                        
                        Button("Hybrid") {
                            mapStyle = .hybrid
                            mapStyleLabel = "Hybrid"
                            mapThemeColor = .white
                            mapAnnotationColor = .blue
                            mapTextColor = .black
                            mapLineColor = .blue
                        }
                        
                        Button("Hybrid(3D)") {
                            mapStyle = .imagery(elevation: .realistic)
                            mapStyleLabel = "Hybrid(3D)"
                            mapThemeColor = .white
                            mapAnnotationColor = .blue
                            mapTextColor = .black
                            mapLineColor = .blue
                        }
                    } label: {
                        Text(mapStyleLabel)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(mapThemeColor)
                            )
                            .foregroundStyle(mapTextColor)
                    }
                    
                    Spacer()
                }
                
                // Back button
                Button {
                    router.dismissScreen()
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundStyle(mapThemeColor)
                }
                .buttonStyle(.plain)
                .padding(.leading, 20)
            }
            
            // Bottom layer
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    // Return to original track
                    Button {
                        withAnimation {
//                            position = .region(MapUtil.shared.regionForCoordinates(from: track))
                            position = .automatic
                        }
                    } label: {
                        Image(systemName: "location.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundStyle(mapThemeColor)
                    }
                    .buttonStyle(.plain)
                    .padding()

                }
            }
            
        }
        .toolbar(.hidden)
    }
}

#Preview {
    RouterView { router in
        TrackDetailScreen(router: router, track: mockTrack)
    }
}
