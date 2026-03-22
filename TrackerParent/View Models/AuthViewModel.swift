//
//  AuthViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 13/03/2025.
//

import Foundation
import OSLog
import MTAuthHelper

enum CommReqState: Equatable {
    case none
    case loading
    case success
    case failure
}

enum SSOType: Equatable {
    case apple
    case google
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
    var username: String = ""
    var password: String = ""
    private(set) var loginState: CommReqState = .none
    private(set) var errMsg: String?
    private(set) var role: String?
    
    var showSettingsAlert: Bool = false
    var showEnrolAlert: Bool = false
    
    @ObservationIgnored
    private let loginUseCase: LoginUseCaseProtocol
    @ObservationIgnored
    private let loginWithFaceIdUseCase: LoginWithFaceIdUseCaseProtocol
    @ObservationIgnored
    private let loginFirebaseUseCase: LoginFirebaseUseCaseProtocol
    @ObservationIgnored
    private let biometricsUtil: BiometricsUtilProtocol
    
    @ObservationIgnored
    private let logger: Logger
    
    init(
        loginUseCase: LoginUseCaseProtocol = LoginUseCase(),
        loginWithFaceIdUseCase: LoginWithFaceIdUseCaseProtocol = LoginWithFaceIdUseCase(),
        loginFirebaseUseCase: LoginFirebaseUseCaseProtocol = LoginFirebaseUseCase(),
        biometricsUtil: BiometricsUtilProtocol = BiometricsUtil.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.loginUseCase = loginUseCase
        self.loginWithFaceIdUseCase = loginWithFaceIdUseCase
        self.loginFirebaseUseCase = loginFirebaseUseCase
        self.biometricsUtil = biometricsUtil
        
        self.username = userDefaults.string(forKey: "username") ?? ""
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        self.logger = Logger(subsystem: bundleId, category: String(describing: type(of: self)))
    }
    
    // Email login
    func login() async {
        do {
            loginState = .loading
            role = nil
            
            // Validate input
            try validateInput()
            
            // Call login usecase
            guard let authResponse = try await loginUseCase.execute(username: username, password: password) else {
                throw CommError.unknown
            }
            
            if authResponse.isSuccess, let authModel = authResponse.value {
                role = authModel.user?.role ?? "User"
                loginState = .success
                errMsg = nil
            } else if !authResponse.isSuccess, let failureReason = authResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleError(error)
        }
    }
    
    // FaceId
    func loginWithFaceId() async {
        do {
            loginState = .loading
            
            if try await biometricsUtil.canUseBiometrics() {
                guard let userResponse = try await loginWithFaceIdUseCase.execute() else {
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
                loginState = .none
                errMsg = nil
            }
        } catch {
            handleError(error)
        }
    }
    
    // Login SSO
    func loginWithSSO(type: SSOType) async {
        do {
            // Call login firebase usecase
            guard let authResponse = try await loginFirebaseUseCase.execute(type: type) else {
                throw CommError.unknown
            }
            
            if authResponse.isSuccess, let authModel = authResponse.value {
                role = authModel.user?.role ?? "User"
                loginState = .success
                errMsg = nil
            } else if !authResponse.isSuccess, let failureReason = authResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleError(error)
        }
    }
}

// MARK: - Validator and error handler
extension AuthViewModel {
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
    
    private func handleError(_ error: Error) {
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        self.loginState = .failure
        self.role = nil
        //        }
        
        switch error {
        case let loginError as LoginError:
            errMsg = loginError.errorDescription
        case let authError as MTAuthError:
            errMsg = authError.localizedDescription
        case BiometryError.notEnroll:
            showEnrolAlert = true
        case BiometryError.notAvailable:
            showSettingsAlert = true
        case BiometryError.other(let otherError):
            errMsg = otherError.localizedDescription
        case let commError as CommError:
            errMsg = commError.errorDescription
        default:
            errMsg = "\(error)" //error.localizedDescription
        }
    }
}
