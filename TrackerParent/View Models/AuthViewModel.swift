//
//  AuthViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 13/03/2025.
//

import Foundation
import MTAuthHelper

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
protocol AuthViewModelProtocol {
    var username: String { get set }
    var password: String { get set }
    var loginState: CommReqState { get }
    var errMsg: String? { get }
    var role: AccountRole? { get }
    var showSettingsAlert: Bool { get set }
    var showEnrolAlert: Bool { get set }
    var faceIdEnabled: Bool { get set }
    var showFaceIdAlert: Bool { get set }
    var hasPromptedEnableFaceId: Bool { get set }
    
    func login() async
    func loginWithFaceId() async
    func loginWithSSO(type: SSOType) async
    
    func updateFaceIdStatus(faceIdEnabled: Bool, hasPrompted: Bool)
}

@Observable
final class AuthViewModel: AuthViewModelProtocol, Loggable {
    var username: String = ""
    var password: String = ""
    private(set) var loginState: CommReqState = .none
    private(set) var errMsg: String?
    private(set) var role: AccountRole?
    var faceIdEnabled: Bool
    var hasPromptedEnableFaceId: Bool
    var showFaceIdAlert: Bool = false
    
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
    private let userDefaults: UserDefaults
    
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
        self.userDefaults = userDefaults
        
        if let username = userDefaults.string(forKey: "username"), !username.isEmpty {
            self.username = username
            self.faceIdEnabled = userDefaults.bool(forKey: "\(username)_faceIdEnabled")
            self.hasPromptedEnableFaceId = userDefaults.bool(forKey: "\(username)_hasPromptedEnableFaceId")
        } else {
            self.username = ""
            self.faceIdEnabled = false
            self.hasPromptedEnableFaceId = false
        }
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
                role = AccountRole(rawValue: authModel.user?.role ?? AccountRole.user.rawValue)
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
            errMsg = nil
            role = nil
            
            guard try await biometricsUtil.canUseBiometrics() else {
                loginState = .none
                return
            }
            
            guard let authModel = try await loginWithFaceIdUseCase.execute() else {
                throw CommError.unknown
            }

            role = AccountRole(rawValue: authModel.user?.role ?? AccountRole.user.rawValue)
            loginState = .success
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
                role = AccountRole(rawValue: authModel.user?.role ?? AccountRole.user.rawValue)
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

extension AuthViewModel {
    func updateFaceIdStatus(faceIdEnabled: Bool, hasPrompted: Bool) {
        userDefaults.set(faceIdEnabled, forKey: "\(username)_faceIdEnabled")
        userDefaults.set(hasPrompted, forKey: "\(username)_hasPromptedEnableFaceId")
        self.faceIdEnabled = faceIdEnabled
        self.hasPromptedEnableFaceId = hasPrompted
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
            errMsg = error.localizedDescription
        }
    }
}
