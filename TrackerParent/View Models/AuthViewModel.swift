//
//  AuthViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 13/03/2025.
//

import Foundation
import OSLog

enum LoginState {
    case none
    case loading
    case success
    case failure
}

enum LoginError: Error {
    case emptyUsername
    case emptyPassword
    case invalidCredentials
    
    var errorDescription: String? {
        switch self {
        case .emptyUsername:
            return "Username is required."
        case .emptyPassword:
            return "Password is required."
        case .invalidCredentials:
            return "Invalid username or password."
        }
    }
}

enum CommError: Error {
    case serverReturnedError(String)
    case noData
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .serverReturnedError(let msg):
            return msg
        case .noData:
            return "No data error."
        case .unknown:
            return "Unknown error."
        }
    }
}

@MainActor
@Observable
final class AuthViewModel {
    var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    var password: String = ""
    var loginState: LoginState = .none
    var errMsg: String?
    var role: String?
    
    var showSettingsAlert: Bool = false
    var showEnrolAlert: Bool = false
    
    @ObservationIgnored
    private let loginService: LoginServiceProtocol
    @ObservationIgnored
    private let userService: UserServiceProtocol
    
    @ObservationIgnored
    private let logger: Logger
    
    init(
        loginService: LoginServiceProtocol = LoginService(),
        userService: UserServiceProtocol = UserService()
    ) {
        self.loginService = loginService
        self.userService = userService
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        self.logger = Logger(subsystem: bundleId, category: String(describing: type(of: self)))
    }
    
    func login() async {
        do {
            loginState = .loading
            role = nil
            
            // Validate input
            try validateInput()
            
            // Call login service
            guard let authResponse = try await loginService.login(username: username, password: password) else {
                throw CommError.unknown
            }
            
            if authResponse.isSuccess, let authModel = authResponse.value {
                logger.debug("--- auth model: \(String(describing: authModel))")
                
                // Save the username to UserDefault
                UserDefaults.standard.set(username, forKey: "username")
                
                // Save the auth model to Keychain
                let bundleId = Bundle.main.bundleIdentifier ?? ""
                try KeyChainUtil.shared.saveObject(service: bundleId, account: username, object: authModel)
                
                role = authModel.userRole
                loginState = .success
                errMsg = nil
            } else if !authResponse.isSuccess, let failureReason = authResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleLoginError(error)
        }
    }
    
    func loginWithFaceId() async {
        do {
            loginState = .loading
            
            if try await BiometricsUtil.shared.canUseBiometrics() {
                let bundleId = Bundle.main.bundleIdentifier ?? ""
                let account = UserDefaults.standard.string(forKey: "username") ?? ""
                if let savedAuthModel = try KeyChainUtil.shared.loadObject(service: bundleId, account: account, type: AuthModel.self) {
                    logger.debug("--- auth model in keychain: \(String(describing: savedAuthModel))")
                    guard let userResponse = try await userService.getUserInfo(username: account) else {
                        throw CommError.unknown
                    }
                    
                    if userResponse.isSuccess, let userModel = userResponse.value {
                        logger.debug("--- user info: \(String(describing: userModel))")
                        
                        role = userModel.role
                        loginState = .success
                        errMsg = nil
                    } else if !userResponse.isSuccess, let failureReason = userResponse.failureReason {
                        throw CommError.serverReturnedError(failureReason)
                    } else {
                        throw CommError.unknown
                    }
                }
            } else {
                loginState = .none
                errMsg = nil
            }
        } catch {
            handleBiometricsError(error)
        }
    }
    
    private func validateInput() throws {
        // Validate username cannot be empty
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw LoginError.emptyUsername
        }
        
        // Validate password cannot be empty
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw LoginError.emptyPassword
        }
    }
    
    private func handleLoginError(_ error: Error) {
        loginState = .failure
        role = nil
        
        switch error {
//        case LoginError.emptyUsername:
//            errMsg = LoginError.emptyUsername.errorDescription
//        case LoginError.emptyPassword:
//            errMsg = LoginError.emptyPassword.errorDescription
//        case LoginError.invalidCredentials:
//            errMsg = LoginError.invalidCredentials.errorDescription
        case let loginError as LoginError:
            errMsg = loginError.errorDescription
        case let commError as CommError:
            errMsg = commError.errorDescription
        default:
            errMsg = error.localizedDescription
        }
    }
    
    private func handleBiometricsError(_ error: Error) {
        loginState = .failure
        role = nil
        
        switch error {
        case BiometryError.notEnroll:
            showEnrolAlert = true
        case BiometryError.notAvailable:
            showSettingsAlert = true
        case BiometryError.other(let otherError):
            errMsg = otherError.localizedDescription
        default:
            errMsg = error.localizedDescription
        }
    }
}
