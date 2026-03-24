//
//  SettingListScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 30/03/2025.
//

import SwiftUI
import SwiftfulRouting

struct SettingListScreen: View {
    @Environment(\.router) private var router
    @Environment(\.appCoordinator) private var appCoordinator
    
    @Environment(ToastViewObserver.self) var toastViewObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var showingDeleteConfirmation = false
    
    @State private var settingViewModel: SettingViewModelProtocol
    
    init(settingViewModel: SettingViewModelProtocol = SettingViewModel()) {
        self.settingViewModel = settingViewModel
    }

    var body: some View {
        VStack {
            switch settingViewModel.fetchDataState {
            case .done:
                if settingViewModel.settingList != nil && !(settingViewModel.settingList?.isEmpty ?? false) {
                    List {
                        ForEach(settingViewModel.settingList ?? [], id: \.self) { setting in
                            SettingListItem(setting: setting)
                                .onTapGesture {
                                    settingViewModel.currentSetting = setting
                                    appCoordinator.setting.show(
                                        .settingDetail(settingViewModel: settingViewModel, isNewSetting: false),
                                        on: router,
                                        horizontalSizeClass: horizontalSizeClass
                                    )
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        settingViewModel.currentSetting = setting
                                        showingDeleteConfirmation = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                } else {
                    Spacer()
                    
                    Text("No track setting for the user.")
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                    
                    Button {
                        settingViewModel.currentSetting = nil
                        appCoordinator.setting.show(
                            .settingDetail(settingViewModel: settingViewModel, isNewSetting: true),
                            on: router,
                            horizontalSizeClass: horizontalSizeClass
                        )
                    } label: {
                        Text("Add New Setting")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 180, height: 40)
                            .background(.primary)
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                }
            case .loading:
                ProgressView("Loading")
                    .progressViewStyle(CircularProgressViewStyle())
            case .error:
                Text("Error:\n\(settingViewModel.errMsg ?? "")")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                Button("Retry") {
                    Task {
                        await settingViewModel.fetchSettingList()
                    }
                }
                .buttonStyle(.borderedProminent)
            case .idle:
                EmptyView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    settingViewModel.currentSetting = nil
                    appCoordinator.setting.show(
                        .settingDetail(settingViewModel: settingViewModel, isNewSetting: true),
                        on: router,
                        horizontalSizeClass: horizontalSizeClass
                    )
                } label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25)
                        .foregroundStyle(.black)
                }
            }
        }
        .onAppear {
            Task {
                if settingViewModel.refreshData {
                    await settingViewModel.fetchSettingList()
                }
            }
        }
        .onChange(of: settingViewModel.deleteDataState, { oldValue, newValue in
            if newValue == .done {
                toastViewObserver.dismissLoading()
                toastViewObserver.showToast(message: "Delete successfully")
                let index = settingViewModel.settingList?.firstIndex(of: settingViewModel.currentSetting ?? SettingModel()) ?? 0
                settingViewModel.settingList?.remove(at: index)
            } else if newValue == .error, let errMsg = settingViewModel.errMsg {
                toastViewObserver.showToast(message: errMsg)
            } else if newValue == .loading {
                toastViewObserver.showLoading()
            }
        })
        .alert("Delete Setting", isPresented: $showingDeleteConfirmation, actions: {
            Button("OK", role: .destructive) {
                Task {
                    await settingViewModel.deleteCurrentSetting()
                }
            }
            Button("Cancel", role: .cancel) { }
        }, message: {
            Text("Confirm to delete this setting?")
        })
        .navigationTitle("Track Setting List")
        .toastView(toastViewObserver: toastViewObserver)
    }
}

// MARK: - Previews
#Preview("setting list") {
    RouterView { _ in
        SettingListScreen(
            settingViewModel: MockSettingViewModel()
        )
    }
    .environment(ToastViewObserver())
}

#Preview("empty data") {
    RouterView { _ in
        SettingListScreen(
            settingViewModel: MockSettingViewModel(shouldReturnEmptyData: true)
        )
    }
    .environment(ToastViewObserver())
}

#Preview("loading") {
    RouterView { _ in
        SettingListScreen(
            settingViewModel: MockSettingViewModel(shouldKeepLoading: true)
        )
    }
    .environment(ToastViewObserver())
}

#Preview("error") {
    RouterView { _ in
        SettingListScreen(
            settingViewModel: MockSettingViewModel(shouldReturnError: true)
        )
    }
    .environment(ToastViewObserver())
}
