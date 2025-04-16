//
//  RegisterViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 09/04/2025.
//

import Foundation
import OSLog

enum RegisterError: Error {
    case emptyEmail
    case emptyVerificationCode
    case emptyPassword
    case emptyConfirmPassword
    case passwordNotMatch
    case invalidEmail
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .emptyEmail:
            return "Email is required."
        case .emptyVerificationCode:
            return "Verification code is required."
        case .emptyPassword:
            return "Password is required."
        case .emptyConfirmPassword:
            return "Confirm password is required."
        case .passwordNotMatch:
            return "Password does not match."
        case .invalidEmail:
            return "Invalid email format."
        case .unknown:
            return "Unknown error."
        }
    }
}

@MainActor
protocol RegisterViewModelProtocol {
    var email: String { get set }
    var verificationCode: String { get set }
    var password: String { get set }
    var confirmPassword: String { get set }
    var registerState: CommReqState { get set }
    var errMsg: String? { get }
    
    var resendCountDown: Int { get }
    func startCountDown()
    func stopCountDown()
    
    func requestVerificationCode() async
    func verifyEmail() async
    func register() async
}

@MainActor
@Observable
final class RegisterViewModel: RegisterViewModelProtocol {
    var email: String = ""
    var verificationCode: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var registerState: CommReqState
    var errMsg: String?
    
    static var timeLeft: Int = 0
    var resendCountDown: Int = RegisterViewModel.timeLeft // RESEND_VERI_CODE_COUNTDOWN_IN_SEC    // in seconds
    @ObservationIgnored
    private var countDownTimer: Timer?
    
    @ObservationIgnored
    private let userService: UserServiceProtocol
    @ObservationIgnored
    private let loginService: LoginServiceProtocol
    @ObservationIgnored
    private let keyChainUtil: KeyChainUtilProtocol
    @ObservationIgnored
    private let userDefaults: UserDefaults
    @ObservationIgnored
    private let logger: Logger
    
    init(
        userService: UserServiceProtocol = UserService(),
        loginService: LoginServiceProtocol = LoginService(),
        keyChainUtil: KeyChainUtilProtocol = KeyChainUtil.shared,
        userDefaults: UserDefaults = .standard,
        registerState: CommReqState = .none,
        errMsg: String? = nil
    ) {
        self.userService = userService
        self.loginService = loginService
        self.keyChainUtil = keyChainUtil
        self.userDefaults = userDefaults
        self.registerState = registerState
        self.errMsg = errMsg
        
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        self.logger = Logger(subsystem: bundleId, category: String(describing: type(of: self)))
    }
    
    func requestVerificationCode() async {
        do {
            registerState = .none
            errMsg = nil
            
            // Validate email
            try validateEmail()

            // 1) Call check user exist service
            guard let userExistResponse = try await userService.checkUserExists(username: email) else {
                throw CommError.unknown
            }
            
            if userExistResponse.isSuccess, userExistResponse.value ?? false {
                throw CommError.serverReturnedError("\(email) is unavailable")
            } else if !userExistResponse.isSuccess, let failureReason = userExistResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            }
            
            // 2) Counting down the retry timer before request the verification code
            startCountDown()

            // 3) Use the super user login to get the token
            guard let authResponse = try await loginService.login(username: "matrixthoughtsadmin", password: "Nbq4dcz123") else {
                throw CommError.unknown
            }
//            guard let authResponse = try await loginService.login(username: "withouthammer", password: "withouthammer") else {
//                throw CommError.unknown
//            }
            
            if authResponse.isSuccess, let authModel = authResponse.value {
                logger.debug("--- super user auth model: \(String(describing: authModel))")
                
                // Save the super user auth model to Keychain for registration use
                try keyChainUtil.saveObject(account: email, object: authModel)
            } else if !authResponse.isSuccess, let failureReason = authResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
            
            // 4) Call send verification email service with super user's token
            guard let authResponse = try await userService.sendVerificationEmail(username: email) else {
                throw CommError.unknown
            }
            
            if authResponse.isSuccess, let authModel = authResponse.value {
                logger.debug("--- auth model: \(String(describing: authModel))")
                
                // Save user auth model to Keychain
                try keyChainUtil.saveObject(account: email, object: authModel)
                
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
    
    func verifyEmail() async {
        do {
            registerState = .loading
            errMsg = nil
            
            // Validate email and code
            try validateEmailAndCode()
            
            // Call verify code service
            guard let userResponse = try await userService.verifyEmail(username: email, code: verificationCode) else {
                throw CommError.unknown
            }
            
            if userResponse.isSuccess, let userModel = userResponse.value {
                logger.debug("--- user model: \(String(describing: userModel))")
                
                registerState = .success
                errMsg = nil
            } else if !userResponse.isSuccess, let failureReason = userResponse.failureReason {
                throw CommError.serverReturnedError(failureReason)
            } else {
                throw CommError.unknown
            }
        } catch {
            handleError(error)
        }
    }
    
    func register() async {
        do {
            registerState = .loading
            errMsg = nil
            
            // Validate password
            try validatePassword()
            
            // Call complete registration service
            guard let authResponse = try await userService.completeRegister(username: email, password: password) else {
                throw CommError.unknown
            }
            
            if authResponse.isSuccess, let authModel = authResponse.value {
                logger.debug("--- auth model after register: \(String(describing: authModel))")
                
                // Save the username to UserDefault
                userDefaults.set(email, forKey: "username")
                
                // Save the auth model to Keychain
                try keyChainUtil.saveObject(account: email, object: authModel)
                
                // Reset the time left when finish registration
                RegisterViewModel.timeLeft = 0
                
                registerState = .success
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
    
    func startCountDown() {
        resendCountDown = RegisterViewModel.timeLeft
        if resendCountDown == 0 {
            resendCountDown = RESEND_VERI_CODE_COUNTDOWN_IN_SEC
        }
        countDownTimer?.invalidate()
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.resendCountDown -= 1
                if self.resendCountDown == 0 {
                    self.countDownTimer?.invalidate()
                }
                RegisterViewModel.timeLeft = self.resendCountDown
            }
        }
    }
    
    func stopCountDown() {
        countDownTimer?.invalidate()
        countDownTimer = nil
    }
    
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
    
    private func validateEmailAndCode() throws {
        // Validate email
        try validateEmail()
        
        // Validate verification code cannot be empty
        guard !verificationCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RegisterError.emptyVerificationCode
        }
    }
    
    private func validatePassword() throws {
        // Validate password cannot be empty
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RegisterError.emptyPassword
        }
        
        // Validate confirm password cannot be empty
        guard !confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RegisterError.emptyConfirmPassword
        }
        
        // Validate password should be matched
        guard password == confirmPassword else {
            throw RegisterError.passwordNotMatch
        }
    }

    private func handleError(_ error: Error) {
        logger.log("Error state: \(error.localizedDescription)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.registerState = .failure
        }
        
        switch error {
        case let registerError as RegisterError:
            errMsg = registerError.errorDescription
        case let commError as CommError:
            errMsg = commError.errorDescription
        default:
            errMsg = error.localizedDescription
        }
    }
}
