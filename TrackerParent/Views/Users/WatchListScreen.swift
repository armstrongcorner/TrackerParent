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
                Text("Active Monitors")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !vm.watchList.isEmpty {
                    Text("Select a primary account to track in real-time")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if vm.watchList.isEmpty {
                    VStack {
                        Image(systemName: "eye.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.mainTheme)
                            .frame(width: 50, height: 50)
                            .padding(30)
                            .background(
                                Circle()
                                    .fill(.reversePrimaryText)
                            )
                            .overlay {
                                Circle()
                                    .stroke(
                                        .primaryText.opacity(0.1),
                                        lineWidth: 0.5
                                    )
                            }
                            .padding(.bottom, 30)
                        
                        Text("No active monitors yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primaryText)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 20)
                        
                        Text("Add a user to start tracking their location and activity status in real-time across you dashboard.")
                            .font(.title3)
                            .fontWeight(.regular)
                            .foregroundStyle(.secondaryText)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 30)
                        
                        // Invite user button
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "person.fill.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.reversePrimaryText)
                                    .frame(width: 25, height: 25)
                                
                                Text("Invite User")
                                    .font(.headline)
                            }
                            .outlineRoundedButtonStyle(
                                buttonBackground: AnyShapeStyle(
                                    LinearGradient(
                                        colors: [.mainTheme, .mainTheme.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing)
                                ),
                                buttonTextColor: .white,
                                outlineWidth: 0
                            )
                            .shadow(color: .mainTheme, radius: 3, x: 0, y: 3)
                        }
                        .withPressableButtonStyle()
                        
                        // View invitation history button
                        Button {
                            
                        } label: {
                            Text("View Invitation History  >")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundStyle(.mainTheme)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                        .withPressableButtonStyle()
                    }
                    .padding(35)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(.outline.opacity(0.2))
                    )
                    .padding()
                } else {
                    // Watch list view
                    List {
                        ForEach(vm.watchList, id: \.self) { watchRelationship in
                            WatchedUserView(watchRelationship)
                        }
                    }
                    .listStyle(.plain)
                    .padding(.vertical, 15)
                }
                
                Spacer()
                
                Button {
                    vm.showAddWatchSheet = true
                } label: {
                    Text("Hello, World!")
                }
            }
            .padding(.horizontal)
        }
        .task {
            await vm.fetchInvitationsAndWatchedUserList()
            let _ = print(vm.invitations.count)
            let _ = print(vm.watchList.count)
        }
        .onChange(of: vm.showAddWatchSheet) { _, newValue in
//            if newValue {
//                let config = ResizableSheetConfig(
//                    detents: [.fraction(0.8), .large],
//                    dragIndicator: .automatic,
//                    backgroundInteraction: .disabled
//                )
//                appCoordinator.user.show(
//                    .sendInvitation(AnyView(SendInvitationScreen(vm: vm))),
//                    on: router,
//                    sheetConfig: config
//                )
//            }
        }
    }
}

// MARK: - View sections
extension WatchListScreen {
//    private watchListContentView: some View {
//        
//    }
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
