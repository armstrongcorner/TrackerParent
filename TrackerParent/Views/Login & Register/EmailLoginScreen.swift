//
//  EmailLoginScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 11/04/2026.
//

import SwiftUI

struct EmailLoginScreen: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.authViewModel) var vm: AuthViewModelProtocol?
    @Environment(\.router) private var router
    @Environment(\.appCoordinator) private var appCoordinator
    
    var body: some View {
        Text("Email login")
    }
}

#Preview {
    EmailLoginScreen()
}
