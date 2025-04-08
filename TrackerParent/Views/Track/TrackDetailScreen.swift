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
    
    @State private var displayedLocations: [LocationModel]
    
    @State private var position: MapCameraPosition
    @State private var mapStyle: MapStyle = .standard
    @State private var mapStyleLabel: String = "Standard"
    @State private var mapThemeColor: Color = .gray
    @State private var mapAnnotationColor: Color = .black
    @State private var mapTextColor: Color = .white
    @State private var mapLineColor: Color = .gray
    @State private var mapUserRotationAngle: Double = 0
    
    init(router: AnyRouter, track: [LocationModel]) {
        self.router = router
        self.track = track
        
        // Calculate the original region to cover all locations of the track
//        self.position = .region(MapUtil.shared.regionForCoordinates(from: track))
        self.position = .automatic
        self.displayedLocations = track
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(position: $position) {
                ForEach(0..<track.count, id: \.self) { i in
                    let locationModel = track[i]
                    let coordinate = CLLocationCoordinate2D(
                        latitude: Double(locationModel.latitude) ?? 0,
                        longitude: Double(locationModel.longitude) ?? 0
                    )
                    
                    Annotation("\(locationModel.id)", coordinate: coordinate) {
                        let displayAnnotation = displayedLocations.contains { $0.id == locationModel.id }
                        if displayAnnotation {
                            Button {
                                print("coordinate: \(coordinate)")
                            } label: {
                                /// Direction
                                /// 0 - North;
                                /// -1 - No direction captured
                                /// x - Angle degree by clockwise from North
                                let directionValue = Double(locationModel.direction ?? "0") ?? 0
                                var imageName = "location.north.fill"
                                if i == 0 {
                                    // Start of the track
                                    imageName = "figure.walk.motion"
                                } else if i == track.count - 1 {
                                    // End of the track
                                    imageName = "flag.pattern.checkered"
                                } else if directionValue > 0 {
                                    // Middle point of the track
                                    imageName = "location.north.fill"
                                } else {
                                    // No heading captured
                                    imageName = "smallcircle.filled.circle.fill"
                                }
                                
                                return Image(systemName: imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: i == 0 || i == track.count - 1 ? 30 : 15)
                                    .rotationEffect(Angle(degrees: i == 0 || i == track.count - 1 ? 0 : directionValue - mapUserRotationAngle))
                                    .foregroundStyle(mapAnnotationColor)
                            }
                            .buttonStyle(.plain)
                        } else {
                            EmptyView()
                        }
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
            .onMapCameraChange({ context in
                let longDelta = context.region.span.longitudeDelta
                    let latDelta = context.region.span.latitudeDelta
                    let effectiveZoom = sqrt(longDelta * latDelta)
                    
                // 根据 effectiveZoom 设定不同的抽样策略，并保证始终保留首尾两个点
                if effectiveZoom > 0.07 {
                    // 地图显示范围很大（zoom out），抽样间隔设置为 15
                    displayedLocations = sampleTrack(from: track, interval: track.count)
                } else if effectiveZoom > 0.05 {
                    // 地图显示范围很大（zoom out），抽样间隔设置为 15
                    displayedLocations = sampleTrack(from: track, interval: 15)
                    print("Using interval: 15")
                } else if effectiveZoom > 0.02 {
                    // 地图显示范围适中，抽样间隔设置为 10
                    displayedLocations = sampleTrack(from: track, interval: 10)
                    print("Using interval: 10")
                } else if effectiveZoom > 0.01 {
                    // 地图显示范围适中，抽样间隔设置为 5
                    displayedLocations = sampleTrack(from: track, interval: 5)
                    print("Using interval: 5")
                } else if effectiveZoom > 0.005 {
                    displayedLocations = sampleTrack(from: track, interval: 3)
                    print("Using interval: 3")
                } else {
                    // 地图显示范围较小，显示所有点
                    displayedLocations = track
                    print("Showing all points")
                }
                
                print("Camera heading: \(context.camera.heading)")
                mapUserRotationAngle = context.camera.heading
            })
            
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
                            mapAnnotationColor = .white
                            mapTextColor = .black
                            mapLineColor = .blue
                        }
                        
                        Button("Hybrid(3D)") {
                            mapStyle = .imagery(elevation: .realistic)
                            mapStyleLabel = "Hybrid(3D)"
                            mapThemeColor = .white
                            mapAnnotationColor = .white
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
                        mapUserRotationAngle = 0
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
    
    // Extract points based on the sampling interval (include the first and last location)
    private func sampleTrack(from fullTrack: [LocationModel], interval: Int) -> [LocationModel] {
        return fullTrack.enumerated().compactMap { index, point in
            return (index == 0 || index == fullTrack.count - 1 || index % interval == 0) ? point : nil
        }
    }
}

#Preview {
    RouterView { router in
        TrackDetailScreen(router: router, track: mockTrack)
    }
}
