//
//  TrackListScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/18.
//

import SwiftUI
import SwiftfulRouting

struct TrackListScreen: View {
    @State private var trackViewModel = TrackViewModel()
    @State private var showConfirmLogout: Bool = false
    
    let router: AnyRouter
    
    init(router: AnyRouter) {
        self.router = router
    }
    
    var body: some View {
        VStack {
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
//            .listStyle(.plain)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        //
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

#Preview {
    RouterView { router in
        TrackListScreen(router: router)
    }
}
