//
//  TrackListScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/18.
//

import SwiftUI
import SwiftfulRouting

struct TrackListScreen: View {
    @State private var trackViewModel: TrackViewModelProtocol
    @State private var showConfirmLogout: Bool = false
    
    let router: AnyRouter
    
    init(
        router: AnyRouter,
        trackViewModel: TrackViewModelProtocol = TrackViewModel()
    ) {
        self.router = router
        self.trackViewModel = trackViewModel
    }
    
    var body: some View {
        VStack {
            switch trackViewModel.fetchDataState {
            case .done:
                List {
                    ForEach(trackViewModel.tracks, id: \.self) { track in
                        Button {
                            router.showScreen(.push) { router2 in
                                TrackDetailScreen(router: router2, track: track)
                            }
                        } label: {
                            TrackListItem(track: track)
                        }
                        .buttonStyle(.plain)
                    }
                }
            case .loading:
                ProgressView("Loading")
                    .progressViewStyle(CircularProgressViewStyle())
            case .error:
                Text("Error:\n\(trackViewModel.errMsg ?? "")")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                Button("Retry") {
                    Task {
                        await trackViewModel.fetchTrack()
                    }
                }
                .buttonStyle(.borderedProminent)
            case .idle:
                EmptyView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        router.showScreen(.push) { router2 in
                            SettingScreen(router: router2)
                        }
                    } label: {
                        Text("Setting")
                    }
                    
                    Button {
                        showConfirmLogout = true
                    } label: {
                        Text("Logout")
                    }
                } label: {
                    Image(systemName: "gearshape")
                }
                .tint(.black)
            }
        }
        .alert("Confirm to logout?", isPresented: $showConfirmLogout) {
            Button("Cancel", role: .cancel) {}
            
            Button("OK", role: .destructive) {
                trackViewModel.logout()
                
                router.dismissScreen()
            }
        } message: {
            Text("Logout current user: \(UserDefaults.standard.string(forKey: "username") ?? "")?")
        }
        .onAppear {
            Task {
                if trackViewModel.tracks.isEmpty {
                    await trackViewModel.fetchTrack()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview("1 track") {
    let mockTrackViewModel = MockTrackViewModel()
    mockTrackViewModel.shouldKeepLoading = false
    mockTrackViewModel.shouldReturnError = false
    
    return RouterView { router in
        TrackListScreen(router: router, trackViewModel: mockTrackViewModel)
    }
}

#Preview("error") {
    let mockTrackViewModel = MockTrackViewModel()
    mockTrackViewModel.shouldKeepLoading = false
    mockTrackViewModel.shouldReturnError = true
    
    return RouterView { router in
        TrackListScreen(router: router, trackViewModel: mockTrackViewModel)
    }
}

#Preview("loading") {
    let mockTrackViewModel = MockTrackViewModel()
    mockTrackViewModel.shouldKeepLoading = true
    mockTrackViewModel.shouldReturnError = false
    
    return RouterView { router in
        TrackListScreen(router: router, trackViewModel: mockTrackViewModel)
    }
}
