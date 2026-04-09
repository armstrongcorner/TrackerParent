//
//  MockWatchInvitationViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 29/03/2026.
//

import Foundation

@Observable
final class MockWatchInvitationViewModel: WatchInvitationViewModelProtocol {
    var email: String = ""
    var message: String = ""
    var invitations: [InvitationModel] = []
    var watchList: [WatchRelationshipModel] = []
    var pendingInvitationList: [PendingInvitationEntity] = []
    var showAddWatchSheet: Bool = false
    var initialRefresh: Bool = true
    
    var fetchDataStatus: RequestStatus = RequestStatus()
    var sendInvitationStatus: RequestStatus = RequestStatus()
    var markAsCurrentWatchStatus: RequestStatus = RequestStatus()
    
    var shouldKeepLoading: Bool
    var shouldReturnError: Bool
    var shouldReturnEmptyData: Bool
    
    init(
        shouldKeepLoading: Bool = false,
        shouldReturnError: Bool = false,
        shouldReturnEmptyData: Bool = false
    ) {
        self.shouldKeepLoading = shouldKeepLoading
        self.shouldReturnError = shouldReturnError
        self.shouldReturnEmptyData = shouldReturnEmptyData
    }
    
    func fetchInvitationsAndWatchedUserList() async {
        // Mock loading
        fetchDataStatus.state = .loading
        fetchDataStatus.errMsg = nil
        
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if !shouldKeepLoading {
            if shouldReturnError {
                // Mock error
                fetchDataStatus.state = .failure
                fetchDataStatus.errMsg = "Mock fetching invitations and watched user list error occurred"
            } else if shouldReturnEmptyData {
                // Mock empty data
                invitations = []
                watchList = []
                showAddWatchSheet = true
                fetchDataStatus.state = .success
            } else {
                // Mock loaded data
                invitations = mockInvitationList
                watchList = mockWatchRelationshipList
                showAddWatchSheet = false
                fetchDataStatus.state = .success
            }
        }
    }
    
    func sendInvitation() async {
        sendInvitationStatus = RequestStatus()
        
        // Validate email cannot be empty
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            sendInvitationStatus.state = .failure
            sendInvitationStatus.errMsg = RegisterError.emptyEmail.errorDescription
            
            return
        }
        
        // Validate email format
        guard StringUtil.shared.isValidEmail(email) else {
            sendInvitationStatus.state = .failure
            sendInvitationStatus.errMsg = RegisterError.invalidEmail.errorDescription
            
            return
        }
        
        // Mock loading
        sendInvitationStatus.state = .loading
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if !shouldKeepLoading {
            if shouldReturnError {
                // Mock error
                sendInvitationStatus.state = .failure
                sendInvitationStatus.errMsg = "Mock sending invitation error occurred"
            } else {
                // Mock return data
                pendingInvitationList.append(PendingInvitationEntity(
                    id: UUID().uuidString,
                    displayName: StringUtil.shared.initials(from: email),
                    email: email,
                    message: ""
                ))
                
                sendInvitationStatus.state = .success
                sendInvitationStatus.errMsg = nil
            }
        }
    }
    
    func markAsCurrentWatch(relationshipId: Int, sessionManger: SessionManager) async {
        guard watchList.contains(where: { $0.id == relationshipId }) else {
            markAsCurrentWatchStatus.state = .failure
            markAsCurrentWatchStatus.errMsg = "Mock relationship not found"
            return
        }
        
        // Mock loading
        markAsCurrentWatchStatus.state = .loading
        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        
        if !shouldKeepLoading {
            if shouldReturnError {
                markAsCurrentWatchStatus.state = .failure
                markAsCurrentWatchStatus.errMsg = "Mock mark current watched user error occurred"
            } else {
                sessionManger.updateCurrentWatchRelationshipId(relationshipId)
                markAsCurrentWatchStatus.state = .success
                markAsCurrentWatchStatus.errMsg = nil
            }
        }
    }
}
