//
//  TrackListScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/18.
//

import SwiftUI
import SwiftfulRouting

struct TrackListScreen: View {
    @Environment(\.router) private var router
    @Environment(ToastViewObserver.self) var toastViewObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var trackViewModel: TrackViewModelProtocol
    @State private var userViewModel: UserViewModelProtocol
    @State private var showConfirmLogout: Bool = false
    @State private var showConfirmDelete: Bool = false
    
    @State private var showDateRangePicker = false
    @State private var startDate: Date = .now
    @State private var endDate: Date = .now
    
    let username: String?
    
    init(
        trackViewModel: TrackViewModelProtocol = TrackViewModel(),
        userViewModel: UserViewModelProtocol = UserViewModel(),
        username: String? = nil
    ) {
        self.trackViewModel = trackViewModel
        self.userViewModel = userViewModel
        self.username = username
    }
    
    var body: some View {
        VStack {
            switch trackViewModel.fetchDataState {
            case .done:
                if !trackViewModel.tracks.isEmpty {
                    List {
                        ForEach(trackViewModel.tracks, id: \.self) { track in
                            Button {
                                router.showScreen(.push) { _ in
                                    TrackDetailScreen(track: track)
                                }
                            } label: {
                                TrackListItem(track: track)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    // Show empty tip
                    Spacer()
                    
                    Text("No track data for this date range.")
                        .foregroundColor(.secondary)
                    
                    Spacer()
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
                    // Track setting
                    Button {
                        router.showScreen(.push) { _ in
                            SettingListScreen()
                        }
                    } label: {
                        Text("Track setting")
                    }
                    
                    // No delete user func for admin role
                    if username == nil {
                        // Delete user
                        Button {
                            showConfirmDelete.toggle()
                        } label: {
                            Text("Delete user")
                        }
                    }

                    // Logout
                    Button {
                        showConfirmLogout.toggle()
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
                userViewModel.logout()
                router.dismissPushStack()
            }
        } message: {
            Text("Logout current user: \(userViewModel.getCurrentUsername())?")
        }
        .alert("Confirm to delete this user?", isPresented: $showConfirmDelete) {
            Button("Cancel", role: .cancel) {}
            
            Button("Confirm", role: .destructive) {
                Task {
                    await userViewModel.deactivateUser()
                }
            }
        } message: {
            Text("After deleting your account, your data will no longer be saved in this application, and you will no longer be able to use this account to log in to this application. If you want to continue using your account after deleting it, please register again.\n\nAre you sure to delete the account:\n\(userViewModel.getCurrentUsername()) ?")
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
                .presentationDetents([.fraction(horizontalSizeClass == .compact ? 0.4 : 0.5)])
        }
        .onChange(of: [startDate, endDate], { oldValue, newValue in
            Task {
                await trackViewModel.fetchTrack(username: username, fromDate: startDate, toDate: endDate)
            }
        })
        .onChange(of: userViewModel.fetchDataState, { oldValue, newValue in
            switch newValue {
            case .idle:
                toastViewObserver.dismissLoading()
            case .loading:
                toastViewObserver.showLoading()
            case .done:
                toastViewObserver.dismissLoading()
                router.dismissPushStack()
            case .error:
                if let errMsg = userViewModel.errMsg {
                    toastViewObserver.showToast(message: errMsg)
                }
            }
        })
        .toastView(toastViewObserver: toastViewObserver)
        .navigationBarBackButtonHidden(username == nil)
    }
}

// MARK: - Previews
#Preview("empty data") {
    RouterView { _ in
        TrackListScreen(
            trackViewModel: MockTrackViewModel(shouldReturnEmptyData: true),
            userViewModel: MockUserViewModel()
        )
    }
    .environment(ToastViewObserver())
}

#Preview("without username") {
    RouterView { _ in
        TrackListScreen(
            trackViewModel: MockTrackViewModel(),
            userViewModel: MockUserViewModel()
        )
    }
    .environment(ToastViewObserver())
}

#Preview("with username") {
    RouterView { _ in
        TrackListScreen(
            trackViewModel: MockTrackViewModel(),
            userViewModel: MockUserViewModel(),
            username: "testUsername"
        )
    }
    .environment(ToastViewObserver())
}

#Preview("delete user") {
    RouterView { _ in
        TrackListScreen(
            trackViewModel: MockTrackViewModel(),
            userViewModel: MockUserViewModel()
        )
    }
    .environment(ToastViewObserver())
}

#Preview("delete user error") {
    RouterView { _ in
        TrackListScreen(
            trackViewModel: MockTrackViewModel(),
            userViewModel: MockUserViewModel(shouldReturnError: true)
        )
    }
    .environment(ToastViewObserver())
}

#Preview("loading error") {
    RouterView { _ in
        TrackListScreen(
            trackViewModel: MockTrackViewModel(shouldReturnError: true)
        )
    }
    .environment(ToastViewObserver())
}

#Preview("loading") {
    RouterView { _ in
        TrackListScreen(
            trackViewModel: MockTrackViewModel(shouldKeepLoading: true)
        )
    }
    .environment(ToastViewObserver())
}
