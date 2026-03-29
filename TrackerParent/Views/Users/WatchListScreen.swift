//
//  WatchListScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 25/03/2026.
//

import SwiftUI
import SwiftfulRouting

struct WatchListScreen<VM: WatchInvitationViewModelProtocol>: View {
    @Environment(\.router) private var router
    @Environment(\.appCoordinator) private var appCoordinator
    @Environment(ToastViewObserver.self) private var toastViewObserver
    
    @State private var vm: VM
    
    init(vm: VM = WatchInvitationViewModel()) {
        _vm = State(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Button {
                    vm.showAddWatchSheet = true
                } label: {
                    Text("Hello, World!")
                }
            }
        }
        .task {
            await vm.fetchInvitationsAndWatchedUserList()
            let _ = print(vm.invitations.count)
            let _ = print(vm.watchList.count)
        }
        .onChange(of: vm.showAddWatchSheet) { _, newValue in
            if newValue {
                let config = ResizableSheetConfig(
                    detents: [.fraction(0.8), .large],
                    dragIndicator: .automatic,
                    backgroundInteraction: .disabled
                )
                appCoordinator.user.show(
                    .sendInvitation(AnyView(SendInvitationScreen(vm: vm))),
                    on: router,
                    sheetConfig: config
                )
            }
        }
    }
}

// MARK: - Previews
#Preview("Normal") {
    let mockVM = MockWatchInvitationViewModel()
    
    return RouterView { _ in
        WatchListScreen(vm: mockVM)
    }
    .environment(ToastViewObserver())
}

#Preview("Empty invitations & watch list") {
    let mockVM = MockWatchInvitationViewModel(shouldReturnEmptyData: true)

    return RouterView { _ in
        WatchListScreen(vm: mockVM)
    }
    .environment(ToastViewObserver())
}
