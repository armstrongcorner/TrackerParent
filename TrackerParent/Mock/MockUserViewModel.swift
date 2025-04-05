//
//  MockUserViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 05/04/2025.
//

import Foundation

@MainActor
@Observable
final class MockUserViewModel: UserViewModelProtocol {
    var users: [UserModel] = []
    var fetchDataState: FetchDataState = .idle
    var errMsg: String? = nil
    
    var shouldKeepLoading = false
    var shouldReturnError = false

    func fetchUsers() async {
        // Mock loading
        fetchDataState = .loading
        errMsg = nil
        
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if !shouldKeepLoading {
            if shouldReturnError {
                // Mock error
                fetchDataState = .error
                errMsg = "Mock fetching users error occurred"
            } else {
                // Mock loaded data
                users.append(contentsOf: [mockUser1, mockUser2])
                fetchDataState = .done
            }
        }
    }
    
    func logout() {
        //
    }
}
