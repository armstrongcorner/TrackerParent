//
//  UserListScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 05/04/2025.
//

import SwiftUI
import SwiftfulRouting

struct UserListScreen: View {
    @State private var userViewModel: UserViewModelProtocol
    @State private var showConfirmLogout: Bool = false
    
    let router: AnyRouter
    
    init(
        router: AnyRouter,
        userViewModel: UserViewModelProtocol = UserViewModel()
    ) {
        self.router = router
        self.userViewModel = userViewModel
    }
    
    var body: some View {
        VStack {
            switch userViewModel.fetchDataState {
            case .done:
                List {
                    ForEach(userViewModel.users, id: \.self) { user in
                        Button {
                            router.showScreen(.push) { router2 in
                                TrackListScreen(router: router2, username: user.userName)
                            }
                        } label: {
                            UserListItem(user: user)
                        }
                        .buttonStyle(.plain)
                    }
                }
            case .loading:
                ProgressView("Loading")
                    .progressViewStyle(CircularProgressViewStyle())
            case .error:
                Text("Error:\n\(userViewModel.errMsg ?? "")")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
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
                        router.showScreen(.push) { router2 in
                            SettingListScreen(router: router2)
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
            Text("Logout current user: \(UserDefaults.standard.string(forKey: "username") ?? "")?")
        }
        .onAppear {
            Task {
                if userViewModel.users.isEmpty {
                    await userViewModel.fetchUsers()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview("2 users") {
    let mockUserViewModel = MockUserViewModel()
    mockUserViewModel.shouldKeepLoading = false
    mockUserViewModel.shouldReturnError = false
    
    return RouterView { router in
        UserListScreen(router: router, userViewModel: mockUserViewModel)
    }
}

#Preview("error") {
    let mockUserViewModel = MockUserViewModel()
    mockUserViewModel.shouldKeepLoading = false
    mockUserViewModel.shouldReturnError = true
    
    return RouterView { router in
        UserListScreen(router: router, userViewModel: mockUserViewModel)
    }
}

#Preview("loading") {
    let mockUserViewModel = MockUserViewModel()
    mockUserViewModel.shouldKeepLoading = true
    mockUserViewModel.shouldReturnError = false
    
    return RouterView { router in
        UserListScreen(router: router, userViewModel: mockUserViewModel)
    }
}
