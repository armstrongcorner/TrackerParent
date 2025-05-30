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
    var shouldReturnEmptyData = false

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
            } else if shouldReturnEmptyData {
                // Mock empty data
                fetchDataState = .done
            } else {
                // Mock loaded data
                users.append(contentsOf: [mockUser1, mockUser2])
                fetchDataState = .done
            }
        }
    }
    
    func getCurrentUsername() -> String {
        return "testUsername@test.com"
    }
    
    func deactivateUser() async {
        // Mock loading
        fetchDataState = .loading
        errMsg = nil
        
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if shouldReturnError {
            // Mock deactivate user error
            fetchDataState = .error
            errMsg = "Mock deactivating user error occurred"
        } else {
            fetchDataState = .done
        }
    }
    
    func logout() {}
}
