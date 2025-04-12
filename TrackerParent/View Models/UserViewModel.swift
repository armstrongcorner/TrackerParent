//
//  UserViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 05/04/2025.
//

import Foundation
import OSLog

@MainActor
protocol UserViewModelProtocol {
    var users: [UserModel] { get }
    var fetchDataState: FetchDataState { get }
    var errMsg: String? { get }
    
    func fetchUsers() async
    func getCurrentUsername() -> String
    func deactivateUser() async
    func logout()
}

@MainActor
@Observable
final class UserViewModel: UserViewModelProtocol {
    var users: [UserModel] = []
    var fetchDataState: FetchDataState
    var errMsg: String?

    @ObservationIgnored
    private let userService: UserServiceProtocol
    @ObservationIgnored
    private let keyChainUtil: KeyChainUtilProtocol
    @ObservationIgnored
    private let userDefaults: UserDefaults

    @ObservationIgnored
    private let logger: Logger
    
    init(
        userService: UserServiceProtocol = UserService(),
        keyChainUtil: KeyChainUtilProtocol = KeyChainUtil.shared,
        userDefaults: UserDefaults = .standard,
        fetchDataState: FetchDataState = .idle,
        errMsg: String? = nil
    ) {
        self.userService = userService
        self.keyChainUtil = keyChainUtil
        self.userDefaults = userDefaults
        self.fetchDataState = fetchDataState
        self.errMsg = errMsg
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        self.logger = Logger(subsystem: bundleId, category: String(describing: type(of: self)))
    }
    
    func fetchUsers() async {
        do {
            users = []
            fetchDataState = .loading
            errMsg = nil
            
            // Call get user list service
            guard let userListResponse = try await userService.getUserList() else {
                throw CommError.unknown
            }
            
            if userListResponse.isSuccess, let userList = userListResponse.value {
                logger.debug("--- users count: \(String(describing: userList.count))")
                
                users = userList
                fetchDataState = .done
                errMsg = nil
            } else if !userListResponse.isSuccess, let failureReason = userListResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleError(error)
        }
    }
    
    func getCurrentUsername() -> String {
        return userDefaults.string(forKey: "username") ?? ""
    }
    
    func deactivateUser() async {
        do {
            fetchDataState = .loading
            errMsg = nil
            
            // 1) Call get user info service
            let username = userDefaults.string(forKey: "username") ?? ""
            guard let userInfoResponse = try await userService.getUserInfo(username: username) else {
                throw CommError.unknown
            }
            
            var newUserModel: UserModel
            if userInfoResponse.isSuccess, let userInfoModel = userInfoResponse.value {
                logger.debug("--- user info model: \(String(describing: userInfoModel))")
                newUserModel = userInfoModel
            } else if !userInfoResponse.isSuccess, let failureReason = userInfoResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
            
            // 2) Call deactivate user service
            newUserModel.isActive = false
            guard let deactivateUserResponse = try await userService.updateUserInfo(newUserModel: newUserModel) else {
                throw CommError.unknown
            }
            
            if deactivateUserResponse.isSuccess, let deactivateUserModel = deactivateUserResponse.value {
                logger.debug("--- deactivated user info model: \(String(describing: deactivateUserModel))")
                
                // 3) Logout
                logout()
                
                fetchDataState = .done
                errMsg = nil
            } else if !deactivateUserResponse.isSuccess, let failureReason = deactivateUserResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
            
            fetchDataState = .done
            errMsg = nil
        } catch {
            handleError(error)
        }
    }
    
    func logout() {
        let service = Bundle.main.bundleIdentifier ?? ""
        let account = userDefaults.string(forKey: "username") ?? ""
        
        // Clear cached username
        userDefaults.set(nil, forKey: "username")
        
        // Clear cached authModel in keychain
        keyChainUtil.delete(service: service, account: account)
    }
    
    private func handleError(_ error: Error) {
        logger.log("Error fetching data: \(error.localizedDescription)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.fetchDataState = .error
        }
        
        switch error {
        case let commError as CommError:
            errMsg = commError.errorDescription
        default:
            errMsg = error.localizedDescription
        }
    }
}
