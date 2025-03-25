//
//  SettingScreen.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/22.
//

import SwiftUI
import SwiftfulRouting

struct SettingScreen: View {
    @Environment(ToastViewObserver.self) var toastViewObserver
    
    @State private var settingViewModel: SettingViewModelProtocol
    @State private var startTime: Date = .now
    
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
                // Start time
                DatePicker(selection: Binding(
                    get: {
                        DateUtil.shared.dateForTimeStr(settingViewModel.setting?.startTime ?? "00:00:00") ?? .now
                    },
                    set: { newDate in
                        settingViewModel.setting?.startTime = DateUtil.shared.getTimeStr(date: newDate)
                    }
                ), displayedComponents: .hourAndMinute) {
                    Text("Start Time:")
                        .fontWeight(.bold)
                }
                .padding(.bottom, 20)
                
                // End time
                DatePicker(selection: Binding(
                    get: {
                        DateUtil.shared.dateForTimeStr(settingViewModel.setting?.endTime ?? "00:00:00") ?? .now
                    },
                    set: { newDate in
                        settingViewModel.setting?.endTime = DateUtil.shared.getTimeStr(date: newDate)
                    }
                ), displayedComponents: .hourAndMinute) {
                    Text("End Time:")
                        .fontWeight(.bold)
                }
                .padding(.bottom, 20)
                
                // DistanceFilter
                HStack {
                    Text("DistanceFilter:")
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    TextField("e.g: 10", text: Binding(
                        get: {
                            String(describing: settingViewModel.setting?.distanceFilter ?? 10)
                        },
                        set: { newValue in
                            if settingViewModel.setting != nil {
                                settingViewModel.setting?.distanceFilter = Int(newValue)
                            } else {
                                settingViewModel.setting = SettingModel()
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
                                settingViewModel.setting?.accuracy = btnTitle
                            } label: {
                                Text(btnTitle)
                            }

                        }
                    } label: {
                        Text(settingViewModel.setting?.accuracy ?? "High")
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
                
                // Update btn
                Button {
                    Task {
                        await settingViewModel.updateSetting()
                    }
                } label: {
                    Text("Update")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 180, height: 45)
                        .background(.blue)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
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
                        await settingViewModel.fetchSetting()
                    }
                }
                .buttonStyle(.borderedProminent)
            case .idle:
                EmptyView()
            }
        }
        .onAppear {
            Task {
                if settingViewModel.setting == nil {
                    await settingViewModel.fetchSetting()
                }
            }
        }
        .onChange(of: settingViewModel.updateDataState, { oldValue, newValue in
            if newValue == .done {
                toastViewObserver.dismissLoading()
                toastViewObserver.showToast(message: "Update successfully")
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

#Preview("setting") {
    let mockSettingViewModel = MockSettingViewModel()
    mockSettingViewModel.shouldKeepLoading = false
    mockSettingViewModel.shouldReturnError = false
    
    return RouterView { router in
        SettingScreen(router: router, settingViewModel: mockSettingViewModel)
    }
    .environment(ToastViewObserver())
}

#Preview("loading") {
    let mockSettingViewModel = MockSettingViewModel()
    mockSettingViewModel.shouldKeepLoading = true
    mockSettingViewModel.shouldReturnError = false
    
    return RouterView { router in
        SettingScreen(router: router, settingViewModel: mockSettingViewModel)
    }
    .environment(ToastViewObserver())
}

#Preview("error") {
    let mockSettingViewModel = MockSettingViewModel()
    mockSettingViewModel.shouldKeepLoading = false
    mockSettingViewModel.shouldReturnError = true
    
    return RouterView { router in
        SettingScreen(router: router, settingViewModel: mockSettingViewModel)
    }
    .environment(ToastViewObserver())
}
