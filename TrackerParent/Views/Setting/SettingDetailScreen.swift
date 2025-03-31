//
//  SettingDetailScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 30/03/2025.
//

import SwiftUI
import SwiftfulRouting

struct SettingDetailScreen: View {
    @Environment(ToastViewObserver.self) var toastViewObserver
    
    @State var settingViewModel: SettingViewModelProtocol
    let router: AnyRouter
    var isNewSetting: Bool
    
    init(
        router: AnyRouter,
        settingViewModel: SettingViewModelProtocol = SettingViewModel(),
        isNewSetting: Bool = false
    ) {
        self.router = router
        self.settingViewModel = settingViewModel
        self.isNewSetting = isNewSetting
        if self.isNewSetting {
            self.settingViewModel.currentSetting = SettingModel(
                userName: UserDefaults.standard.string(forKey: "username"),
                collectionFrequency: 0,
                pushFrequency: 0,
                distanceFilter: 10,
                startTime: "00:00:00",
                endTime: "00:00:00",
                accuracy: "High"
            )
        }
    }
    
    var body: some View {
        LazyVStack {
            // Start time
            DatePicker(selection: Binding(
                get: {
                    DateUtil.shared.dateForTimeStr(settingViewModel.currentSetting?.startTime ?? "00:00:00") ?? .now
                },
                set: { newDate in
                    settingViewModel.currentSetting?.startTime = DateUtil.shared.getTimeStr(date: newDate)
                }
            ), displayedComponents: .hourAndMinute) {
                Text("Start Time:")
                    .fontWeight(.bold)
            }
            .tint(.black)
            .padding(.bottom, 20)
            
            // End time
            DatePicker(selection: Binding(
                get: {
                    DateUtil.shared.dateForTimeStr(settingViewModel.currentSetting?.endTime ?? "00:00:00") ?? .now
                },
                set: { newDate in
                    settingViewModel.currentSetting?.endTime = DateUtil.shared.getTimeStr(date: newDate)
                }
            ), displayedComponents: .hourAndMinute) {
                Text("End Time:")
                    .fontWeight(.bold)
            }
            .tint(.black)
            .padding(.bottom, 20)
            
            // DistanceFilter
            HStack {
                Text("DistanceFilter:")
                    .fontWeight(.bold)
                
                Spacer()
                
                TextField("e.g: 10", text: Binding(
                    get: {
                        String(describing: settingViewModel.currentSetting?.distanceFilter ?? 10)
                    },
                    set: { newValue in
                        if settingViewModel.currentSetting != nil {
                            settingViewModel.currentSetting?.distanceFilter = Int(newValue)
                        } else {
                            settingViewModel.currentSetting = SettingModel()
                        }
                    }
                ))
                .frame(minWidth: 40, idealWidth: 40, maxWidth: 70)
                .multilineTextAlignment(.trailing)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
            }
            .padding(.bottom, 20)
            
            // Accuracy
            HStack {
                Text("Accuracy:")
                    .fontWeight(.bold)
                
                Spacer()
                
                Menu {
                    ForEach(0..<3, id: \.self) { index in
                        var btnTitle = "High"
                        switch index {
                        case 0:
                            btnTitle = "Low"
                        case 1:
                            btnTitle = "Medium"
                        case 2:
                            btnTitle = "High"
                        default:
                            btnTitle = ""
                        }
                        
                        return Button {
                            settingViewModel.currentSetting?.accuracy = btnTitle
                        } label: {
                            Text(btnTitle)
                        }
                    }
                } label: {
                    Text(settingViewModel.currentSetting?.accuracy ?? "High")
                        .frame(width: 80, height: 35)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.15))
                        }
                }
                .foregroundStyle(.black)
                .menuStyle(.automatic)
            }
            .padding(.bottom, 80)
            
            // Add/Update btn
            Button {
                Task {
                    if isNewSetting {
                        await settingViewModel.addNewSetting()
                    } else {
                        await settingViewModel.updateCurrentSetting()
                    }
                }
            } label: {
                Text(isNewSetting ? "Create" : "Update")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 180, height: 45)
                    .background(.blue)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .onChange(of: settingViewModel.updateDataState, { oldValue, newValue in
            if newValue == .done {
                toastViewObserver.dismissLoading()
                toastViewObserver.showToast(message: "Update successfully") {
                    Task {
                        await MainActor.run {
                            router.dismissScreen()
                        }
                    }
                }
            } else if newValue == .error, let errMsg = settingViewModel.errMsg {
                toastViewObserver.showToast(message: errMsg)
            } else if newValue == .loading {
                toastViewObserver.showLoading()
            }
        })
        .onChange(of: settingViewModel.addDataState, { oldValue, newValue in
            if newValue == .done {
                toastViewObserver.dismissLoading()
                toastViewObserver.showToast(message: "Add successfully") {
                    Task {
                        await MainActor.run {
                            router.dismissScreen()
                        }
                    }
                }
            } else if newValue == .error, let errMsg = settingViewModel.errMsg {
                toastViewObserver.showToast(message: errMsg)
            } else if newValue == .loading {
                toastViewObserver.showLoading()
            }
        })
        .padding()
        .toastView(toastViewObserver: toastViewObserver)
    }
}

#Preview("update setting") {
    let mockSettingViewModel = MockSettingViewModel()
    mockSettingViewModel.shouldKeepLoading = false
    mockSettingViewModel.shouldReturnError = false
    mockSettingViewModel.currentSetting = mockSetting1
    
    return RouterView { router in
        SettingDetailScreen(router: router, settingViewModel: mockSettingViewModel)
    }
    .environment(ToastViewObserver())
}

#Preview("create setting") {
    let mockSettingViewModel = MockSettingViewModel()
    mockSettingViewModel.shouldKeepLoading = false
    mockSettingViewModel.shouldReturnError = false
    mockSettingViewModel.currentSetting = nil
    
    return RouterView { router in
        SettingDetailScreen(router: router, settingViewModel: mockSettingViewModel, isNewSetting: true)
    }
    .environment(ToastViewObserver())
}
