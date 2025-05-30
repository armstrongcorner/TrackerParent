//
//  AuthViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 13/03/2025.
//

import Foundation
import OSLog

enum CommReqState {
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
protocol AuthViewModelProtocol {
    var username: String { get set }
    var password: String { get set }
    var loginState: CommReqState { get }
    var errMsg: String? { get }
    var role: String? { get }
    var showSettingsAlert: Bool { get set }
    var showEnrolAlert: Bool { get set }
    
    func login() async
    func loginWithFaceId() async
}

@MainActor
@Observable
final class AuthViewModel: AuthViewModelProtocol {
    var username: String = ""
    var password: String = ""
    var loginState: CommReqState = .none
    var errMsg: String?
    var role: String?
    
    var showSettingsAlert: Bool = false
    var showEnrolAlert: Bool = false
    
    @ObservationIgnored
    private let loginService: LoginServiceProtocol
    @ObservationIgnored
    private let userService: UserServiceProtocol
    @ObservationIgnored
    private let keyChainUtil: KeyChainUtilProtocol
    @ObservationIgnored
    private let biometricsUtil: BiometricsUtilProtocol
    @ObservationIgnored
    private let userDefaults: UserDefaults
    
    @ObservationIgnored
    private let logger: Logger
    
    init(
        loginService: LoginServiceProtocol = LoginService(),
        userService: UserServiceProtocol = UserService(),
        keyChainUtil: KeyChainUtilProtocol = KeyChainUtil.shared,
        biometricsUtil: BiometricsUtilProtocol = BiometricsUtil.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.loginService = loginService
        self.userService = userService
        self.keyChainUtil = keyChainUtil
        self.biometricsUtil = biometricsUtil
        self.userDefaults = userDefaults
        
        self.username = userDefaults.string(forKey: "username") ?? ""
        
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
                userDefaults.set(username, forKey: "username")
                
                // Save the auth model to Keychain
                try keyChainUtil.saveObject(account: username, object: authModel)
                
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
            
            if try await biometricsUtil.canUseBiometrics() {
                let account = userDefaults.string(forKey: "username") ?? ""
                if let savedAuthModel = try keyChainUtil.loadObject(account: account, type: AuthModel.self) {
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
                } else {
                    throw CommError.serverReturnedError("No auth model in keychain")
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loginState = .failure
            self.role = nil
        }
        
        switch error {
        case let loginError as LoginError:
            errMsg = loginError.errorDescription
        case let commError as CommError:
            errMsg = commError.errorDescription
        default:
            errMsg = error.localizedDescription
        }
    }
    
    private func handleBiometricsError(_ error: Error) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loginState = .failure
            self.role = nil
        }
        
        switch error {
        case BiometryError.notEnroll:
            showEnrolAlert = true
        case BiometryError.notAvailable:
            showSettingsAlert = true
        case BiometryError.other(let otherError):
            errMsg = otherError.localizedDescription
        case let commError as CommError:
            errMsg = commError.errorDescription
        default:
            errMsg = error.localizedDescription
        }
    }
}
