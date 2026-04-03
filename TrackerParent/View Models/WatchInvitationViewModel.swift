//
//  WatchInvitationViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 29/03/2026.
//

import Foundation

struct PendingInvitationEntity: Identifiable {
    let id: String
    let displayName: String
    let email: String
    let message: String
    
    init(
        id: String,
        displayName: String,
        email: String,
        message: String = ""
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.message = message
    }
    
    init(from invitationModel: InvitationModel) {
        self.id = invitationModel.id == nil ? UUID().uuidString : String(invitationModel.id ?? 0)
        self.email = invitationModel.inviteeEmail ?? ""
        self.message = invitationModel.message ?? ""
        self.displayName = StringUtil.shared.initials(from: invitationModel.inviteeEmail ?? "")
    }
}

@MainActor
protocol WatchInvitationViewModelProtocol: Observable, AnyObject {
    var email: String { get set }
    var message: String { get set }
    var fetchDataStatus: RequestStatus { get }
    var sendInvitationStatus: RequestStatus { get }
    var invitations: [InvitationModel] { get }
    var watchList: [WatchRelationshipModel] { get }
    var pendingInvitationList: [PendingInvitationEntity] { get }
    var showAddWatchSheet: Bool { get set }
    var initialRefresh: Bool { get }
    
    func fetchInvitationsAndWatchedUserList() async
    func sendInvitation() async
}

@Observable
final class WatchInvitationViewModel: WatchInvitationViewModelProtocol, Loggable {
    var email: String = ""
    var message: String = ""
    private(set) var fetchDataStatus: RequestStatus = RequestStatus()
    private(set) var sendInvitationStatus: RequestStatus = RequestStatus()
    private(set) var invitations: [InvitationModel] = []
    private(set) var watchList: [WatchRelationshipModel] = []
    private(set) var pendingInvitationList: [PendingInvitationEntity] = []
    var showAddWatchSheet: Bool = false
    private(set) var initialRefresh: Bool = true
    
    @ObservationIgnored
    private let userService: UserServiceProtocol
    
    init(userService: UserServiceProtocol = UserService()) {
        self.userService = userService
    }
    
    func fetchInvitationsAndWatchedUserList() async {
        do {
            // Initialize the states
            fetchDataStatus.state = .loading
            fetchDataStatus.errMsg = nil
            initialRefresh = false
            
            // Call get invitations and get watch relationships
            async let invitationsTask = userService.getAllInvitations()
            async let watchRelationshipsTask = userService.getWatchRelationships()
            
            guard
                let invitationListResponse = try await invitationsTask,
                let watchRelationshipListResponse = try await watchRelationshipsTask
            else {
                throw CommError.unknown
            }
            
            // Handle invitation response
            if invitationListResponse.isSuccess, let invitationList = invitationListResponse.value {
                logger.debug("--- invitation list: \(invitationList)")
                
                invitations = invitationList
            } else if !invitationListResponse.isSuccess, let failureReason = invitationListResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
            
            // Handle watched users response
            if watchRelationshipListResponse.isSuccess, let watchRelationshipList = watchRelationshipListResponse.value {
                logger.debug("--- watch relation list: \(watchRelationshipList)")
                
                watchList = watchRelationshipList
            } else if !watchRelationshipListResponse.isSuccess, let failureReason = watchRelationshipListResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
            
            fetchDataStatus.state = .success
            
            // All empty then show add watch list sheet
            if invitations.count == 0 && watchList.count == 0 {
                showAddWatchSheet = true
            }
        } catch {
            handleError(error, for: &fetchDataStatus)
        }
    }
    
    func sendInvitation() async {
        do {
            sendInvitationStatus.state = .none
            sendInvitationStatus.errMsg = nil
            
            // Validate email
            try validateEmail()
            
            // Call send invitation service
            sendInvitationStatus.state = .loading
            
            guard let invitationResponse = try await userService.sendInvitation(email: email, message: message) else {
                throw CommError.unknown
            }
            
            if invitationResponse.isSuccess, let invitation = invitationResponse.value {
                logger.debug("--- send invitation: \(String(describing: invitation))")
                
                pendingInvitationList.append(PendingInvitationEntity(from: invitation))
                sendInvitationStatus.state = .success
                sendInvitationStatus.errMsg = nil
                
                email = ""
                message = ""
                
                // Call refresh list after send invitation
                await fetchInvitationsAndWatchedUserList()
            } else if !invitationResponse.isSuccess, let failureReason = invitationResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleError(error, for: &sendInvitationStatus)
        }
    }
}

extension WatchInvitationViewModel {
    private func validateEmail() throws {
        // Validate email cannot be empty
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RegisterError.emptyEmail
        }
        
        // Validate email format
        guard StringUtil.shared.isValidEmail(email) else {
            throw RegisterError.invalidEmail
        }
    }
    
    private func handleError(_ error: Error, for theStatus: inout RequestStatus) {
        logger.log("Error fetching data: \(error.localizedDescription)")
        
        theStatus.state = .failure
        
        switch error {
        case let commError as CommError:
            theStatus.errMsg = commError.errorDescription
        default:
            theStatus.errMsg = error.localizedDescription
        }
    }
}
