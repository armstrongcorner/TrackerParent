//
//  SettingListScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 30/03/2025.
//

import SwiftUI
import SwiftfulRouting

struct SettingListScreen: View {
    @Environment(ToastViewObserver.self) var toastViewObserver
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var showingDeleteConfirmation = false
    
    @State private var settingViewModel: SettingViewModelProtocol
    let router: AnyRouter
    
    init(
        router: AnyRouter,
        settingViewModel: SettingViewModelProtocol = SettingViewModel()
    ) {
        self.router = router
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
                                    router.showResizableSheet(sheetDetents: [.fraction(horizontalSizeClass == .compact ? 0.5 : 0.7)], selection: nil, showDragIndicator: true) { router2 in
                                        settingViewModel.currentSetting = setting
                                        return SettingDetailScreen(router: router2, settingViewModel: settingViewModel)
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    HStack {
                                        Button(role: .destructive) {
                                            settingViewModel.currentSetting = setting
                                            showingDeleteConfirmation = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                        }
                    }
                } else {
                    // Show empty tip
                    Spacer()
                    
                    Text("No track setting for the user.")
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                    
                    Button {
                        // Add new setting
                        router.showResizableSheet(sheetDetents: [.fraction(horizontalSizeClass == .compact ? 0.5 : 0.7)], selection: nil, showDragIndicator: true) { router2 in
                            settingViewModel.currentSetting = nil
                            return SettingDetailScreen(router: router2, settingViewModel: settingViewModel, isNewSetting: true)
                        }
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
                    // Add new setting
                    router.showResizableSheet(sheetDetents: [.fraction(horizontalSizeClass == .compact ? 0.5 : 0.7)], selection: nil, showDragIndicator: true) { router2 in
                        settingViewModel.currentSetting = nil
                        return SettingDetailScreen(router: router2, settingViewModel: settingViewModel, isNewSetting: true)
                    }
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

#Preview("setting list") {
    let mockSettingViewModel = MockSettingViewModel()
    mockSettingViewModel.shouldKeepLoading = false
    mockSettingViewModel.shouldReturnError = false
    
    return RouterView { router in
        SettingListScreen(router: router, settingViewModel: mockSettingViewModel)
    }
    .environment(ToastViewObserver())
}

#Preview("empty data") {
    let mockSettingViewModel = MockSettingViewModel()
    mockSettingViewModel.shouldKeepLoading = false
    mockSettingViewModel.shouldReturnError = false
    mockSettingViewModel.shouldReturnEmptyData = true
    
    return RouterView { router in
        SettingListScreen(router: router, settingViewModel: mockSettingViewModel)
    }
    .environment(ToastViewObserver())
}

#Preview("loading") {
    let mockSettingViewModel = MockSettingViewModel()
    mockSettingViewModel.shouldKeepLoading = true
    mockSettingViewModel.shouldReturnError = false
    
    return RouterView { router in
        SettingListScreen(router: router, settingViewModel: mockSettingViewModel)
    }
    .environment(ToastViewObserver())
}

#Preview("error") {
    let mockSettingViewModel = MockSettingViewModel()
    mockSettingViewModel.shouldKeepLoading = false
    mockSettingViewModel.shouldReturnError = true
    
    return RouterView { router in
        SettingListScreen(router: router, settingViewModel: mockSettingViewModel)
    }
    .environment(ToastViewObserver())
}
