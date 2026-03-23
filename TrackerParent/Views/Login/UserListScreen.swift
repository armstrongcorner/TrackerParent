//
//  UserListScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 05/04/2025.
//

import SwiftUI
import SwiftfulRouting

struct UserListScreen: View {
    @Environment(\.router) private var router
    @State private var userViewModel: UserViewModelProtocol
    @State private var showConfirmLogout: Bool = false
    
    init(userViewModel: UserViewModelProtocol = UserViewModel()) {
        self.userViewModel = userViewModel
    }
    
    var body: some View {
        VStack {
            switch userViewModel.fetchDataState {
            case .done:
                if !userViewModel.users.isEmpty {
                    List {
                        ForEach(userViewModel.users, id: \.self) { user in
                            Button {
                                router.showScreen(.push) { _ in
                                    TrackListScreen(username: user.username)
                                }
                            } label: {
                                UserListItem(user: user)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    // Show empty tip
                    Spacer()
                    
                    Text("No user data.")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            case .loading:
                ProgressView("Loading")
                    .progressViewStyle(CircularProgressViewStyle())
            case .error:
                let extractedExpr: some View = Text("Error:\n\(userViewModel.errMsg ?? "")")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                extractedExpr
                Button("Retry") {
                    Task {
                        await userViewModel.fetchUsers()
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
                        router.showScreen(.push) { _ in
                            SettingListScreen()
                        }
                    } label: {
                        Text("Track setting")
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
                userViewModel.logout()
                
                router.dismissScreen()
            }
        } message: {
            Text("Logout current user: \(userViewModel.getCurrentUsername())?")
        }
        .onAppear {
            Task {
                if userViewModel.users.isEmpty {
                    await userViewModel.fetchUsers()
                }
            }
        }
        .navigationTitle("User List")
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Previews
#Preview("2 users") {
    RouterView { _ in
        UserListScreen(
            userViewModel: MockUserViewModel()
        )
    }
}

#Preview("empty data") {
    RouterView { _ in
        UserListScreen(
            userViewModel: MockUserViewModel(shouldReturnEmptyData: true)
        )
    }
}

#Preview("error") {
    RouterView { _ in
        UserListScreen(
            userViewModel: MockUserViewModel(shouldReturnError: true)
        )
    }
}

#Preview("loading") {
    RouterView { _ in
        UserListScreen(
            userViewModel: MockUserViewModel(shouldKeepLoading: true)
        )
    }
}
