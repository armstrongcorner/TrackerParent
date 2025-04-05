//
//  TrackListScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/18.
//

import SwiftUI
import SwiftfulRouting

struct TrackListScreen: View {
    @Environment(ToastViewObserver.self) var toastViewObserver
    
    @State private var trackViewModel: TrackViewModelProtocol
    @State private var showConfirmLogout: Bool = false
    
    @State private var showDateRangePicker = false
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    
    let router: AnyRouter
    let username: String?
    
    init(
        router: AnyRouter,
        trackViewModel: TrackViewModelProtocol = TrackViewModel(),
        username: String? = nil
    ) {
        self.router = router
        self.trackViewModel = trackViewModel
        self.username = username
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
                        await trackViewModel.fetchTrack(username: username, fromDate: startDate, toDate: endDate)
                    }
                }
                .buttonStyle(.borderedProminent)
            case .idle:
                EmptyView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button {
                    showDateRangePicker.toggle()
                } label: {
                    Text("\(DateUtil.shared.getDateStr(date: startDate) ?? "") - \(DateUtil.shared.getDateStr(date: endDate) ?? "")")
                        .font(.headline)
                }
                .buttonStyle(.plain)
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        router.showScreen(.push) { router2 in
                            SettingListScreen(router: router2)
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
                    await trackViewModel.fetchTrack(username: username, fromDate: startDate, toDate: endDate)
                }
            }
        }
        .sheet(isPresented: $showDateRangePicker) {
            DateRangePickerView(bindingStartDate: $startDate, bindingEndDate: $endDate)
                .presentationDetents([.fraction(0.4)])
        }
        .onChange(of: [startDate, endDate], { oldValue, newValue in
            Task {
                await trackViewModel.fetchTrack(username: username, fromDate: startDate, toDate: endDate)
            }
        })
        .toastView(toastViewObserver: toastViewObserver)
        .navigationBarBackButtonHidden(username == nil)
    }
}

#Preview("1 track") {
    let mockTrackViewModel = MockTrackViewModel()
    mockTrackViewModel.shouldKeepLoading = false
    mockTrackViewModel.shouldReturnError = false
    
    return RouterView { router in
        TrackListScreen(router: router, trackViewModel: mockTrackViewModel)
    }
    .environment(ToastViewObserver())
}

#Preview("error") {
    let mockTrackViewModel = MockTrackViewModel()
    mockTrackViewModel.shouldKeepLoading = false
    mockTrackViewModel.shouldReturnError = true
    
    return RouterView { router in
        TrackListScreen(router: router, trackViewModel: mockTrackViewModel)
    }
    .environment(ToastViewObserver())
}

#Preview("loading") {
    let mockTrackViewModel = MockTrackViewModel()
    mockTrackViewModel.shouldKeepLoading = true
    mockTrackViewModel.shouldReturnError = false
    
    return RouterView { router in
        TrackListScreen(router: router, trackViewModel: mockTrackViewModel)
    }
    .environment(ToastViewObserver())
}
