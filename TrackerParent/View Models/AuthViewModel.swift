//
//  AuthViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 13/03/2025.
//

import Foundation
import MTAuthHelper
import SwiftUI

enum SSOType: Equatable {
    case apple
    case google
}

enum LoginError: Error {
    case emptyEmail
    case emptyPassword
    case passwordNotMatch
    case invalidEmail
    case invalidCredentials
    
    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Email is required."
        case .emptyPassword:
            return "Password is required."
        case .passwordNotMatch:
            return "Password is not match."
        case .invalidEmail:
            return "Not a valid email."
        case .invalidCredentials:
            return "Invalid email or password."
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

enum EmailFlowDestination: Equatable {
    case none
    case login(flowToken: String)
    case register(flowToken: String)
}

private struct AuthViewModelKey: EnvironmentKey {
    static let defaultValue: AuthViewModelProtocol? = nil
}

extension EnvironmentValues {
    var authViewModel: AuthViewModelProtocol? {
        get { self[AuthViewModelKey.self] }
        set { self[AuthViewModelKey.self] = newValue }
    }
}

@MainActor
protocol AuthViewModelProtocol: Observable, AnyObject, Sendable {
    var username: String { get set }
    var email: String { get set }
    var password: String { get set }
    var confirmPassword: String { get set }
    var loginState: CommReqState { get }
    var emailEntryState: CommReqState { get }
    var emailFlowDestination: EmailFlowDestination { get set }
    var errMsg: String? { get }
    var role: AccountRole? { get }
    var faceIdEnabled: Bool { get set }
    var showFaceIdAlert: Bool { get set }
    var hasPromptedEnableFaceId: Bool { get set }
    var autoTriggerGoogleSignIn: Bool { get set }
    var autoTriggerAppleSignIn: Bool { get set }
    
    var showSettingsAlert: Bool { get set }
    var showEnrolAlert: Bool { get set }
    
    func loginWithEmailStart() async
    func loginWithEmailComplete(flowToken: String) async
    func registerWithEmailComplete(flowToken: String) async
    func loginWithSSO(type: SSOType) async
    func loginWithFaceId() async
    
    func updateFaceIdStatus(faceIdEnabled: Bool, hasPrompted: Bool)
}

@Observable
final class AuthViewModel: AuthViewModelProtocol, Loggable {
    var username: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    private(set) var loginState: CommReqState = .none
    private(set) var emailEntryState: CommReqState = .none
    var emailFlowDestination: EmailFlowDestination = .none
    private(set) var errMsg: String?
    private(set) var role: AccountRole?
    var faceIdEnabled: Bool
    var showFaceIdAlert: Bool = false
    var hasPromptedEnableFaceId: Bool
    var autoTriggerGoogleSignIn: Bool = false
    var autoTriggerAppleSignIn: Bool = false
    
    var showSettingsAlert: Bool = false
    var showEnrolAlert: Bool = false
    
    @ObservationIgnored
    private let loginService: LoginServiceProtocol
    @ObservationIgnored
    private let loginWithEmailUseCase: LoginWithEmailUseCaseProtocol
    @ObservationIgnored
    private let registerWithEmailUseCase: RegisterWithEmailUseCaseProtocol
    @ObservationIgnored
    private let loginWithFaceIdUseCase: LoginWithFaceIdUseCaseProtocol
    @ObservationIgnored
    private let firebaseSSOUseCase: FirebaseSSOUseCaseProtocol
    @ObservationIgnored
    private let loginAfterSSOUseCase: LoginAfterSSOUseCaseProtocol
    @ObservationIgnored
    private let biometricsUtil: BiometricsUtilProtocol
    @ObservationIgnored
    private let userDefaults: UserDefaults
    
    init(
        loginService: LoginServiceProtocol = LoginService(),
        registerWithEmailUseCase: RegisterWithEmailUseCaseProtocol = RegisterWithEmailUseCase(),
        loginWithEmailUseCase: LoginWithEmailUseCaseProtocol = LoginWithEmailUseCase(),
        loginWithFaceIdUseCase: LoginWithFaceIdUseCaseProtocol = LoginWithFaceIdUseCase(),
        firebaseSSOUseCase: FirebaseSSOUseCaseProtocol = FirebaseSSOUseCase(),
        loginAfterSSOUseCase: LoginAfterSSOUseCaseProtocol = LoginAfterSSOUseCase(),
        biometricsUtil: BiometricsUtilProtocol = BiometricsUtil.shared,
        userDefaults: UserDefaults = .standard
    ) {
        self.loginService = loginService
        self.registerWithEmailUseCase = registerWithEmailUseCase
        self.loginWithEmailUseCase = loginWithEmailUseCase
        self.loginWithFaceIdUseCase = loginWithFaceIdUseCase
        self.firebaseSSOUseCase = firebaseSSOUseCase
        self.loginAfterSSOUseCase = loginAfterSSOUseCase
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
    
    convenience init(loginService: LoginServiceProtocol = LoginService()) {
        self.init(
            loginService: loginService,
            registerWithEmailUseCase: RegisterWithEmailUseCase(loginService: loginService),
            loginWithEmailUseCase: LoginWithEmailUseCase(loginService: loginService),
            loginAfterSSOUseCase: LoginAfterSSOUseCase(loginService: loginService),
        )
    }
    
    // Email login/register start
    func loginWithEmailStart() async {
        do {
            // Validate email
            try validateEmail()
            
            emailEntryState = .loading
            
            // Call login email start
            guard let emailFlowStartResponse = try await loginService.loginWithEmailStart(
                email: email,
                deviceId: StringUtil.shared.getDeviceId()
            ) else {
                throw CommError.unknown
            }
            
            if emailFlowStartResponse.isSuccess, let emailFlowStartModel = emailFlowStartResponse.value {
                switch emailFlowStartModel.step {
                case .login:
                    emailEntryState = .success
                    emailFlowDestination = .login(flowToken: emailFlowStartModel.flowToken ?? "")
                case .register:
                    emailEntryState = .success
                    emailFlowDestination = .register(flowToken: emailFlowStartModel.flowToken ?? "")
                default:
                    emailEntryState = .none
                    emailFlowDestination = .none
                }
            } else if !emailFlowStartResponse.isSuccess, let failureReason = emailFlowStartResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleError(error)
        }
    }
    
    // Email login complete
    func loginWithEmailComplete(flowToken: String) async {
        do {
            loginState = .loading
            
            // Call login email complete usecase
            guard let authResponse = try await loginWithEmailUseCase.execute(email: email, password: password, flowToken: flowToken) else {
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
    
    // Email register complete
    func registerWithEmailComplete(flowToken: String) async {
        do {
            // Validate password
            try validatePassword()
            
            loginState = .loading
            
            // Call register with email use case
            guard let authResponse = try await registerWithEmailUseCase.execute(email: email, password: password, flowToken: flowToken) else {
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

    // Login SSO
    func loginWithSSO(type: SSOType) async {
        do {
            // Call firebase SSO usecase
            let idToken = try await firebaseSSOUseCase.execute(type: type)
            
            loginState = .loading
            
            // Call login after SSO usecase
            guard let authResponse = try await loginAfterSSOUseCase.execute(idToken: idToken) else {
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
    private func validateEmail() throws {
        // Validate email cannot be empty
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw LoginError.emptyEmail
        }
        
        guard StringUtil.shared.isValidEmail(email) else {
            throw LoginError.invalidEmail
        }
    }
    
    private func validatePassword() throws {
        // Validate password cannot be empty
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw LoginError.emptyPassword
        }
        
        // Validate confirmed password
        guard confirmPassword == password else {
            throw LoginError.invalidEmail
        }
    }
    
    private func handleError(_ error: Error) {
        self.loginState = .failure
        self.emailEntryState = .failure
        self.role = nil
        
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
