//
//  MockRegisterViewModel.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 09/04/2025.
//

import Foundation

@MainActor
@Observable
final class MockRegisterViewModel: RegisterViewModelProtocol {
    var email: String = ""
    var verificationCode: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var registerState: CommReqState = .none
    var errMsg: String? = nil
    
    var resendCountDown = 0
    
    func startCountDown() {
        //
    }
    
    func stopCountDown() {
        //
    }
    
    func requestVerificationCode() async {
        //
    }
    
    func verifyEmail() async {
        //
    }
    
    func register() async {
        //
    }
    
    
}
