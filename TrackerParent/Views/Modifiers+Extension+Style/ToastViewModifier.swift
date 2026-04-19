//
//  ToastViewModifier.swift
//  sidu
//
//  Created by Armstrong Liu on 31/08/2024.
//

import SwiftUI

enum ToastType {
    case loading
    case toast
}

@MainActor
@Observable
class ToastViewObserver {
    // Show toast
    var isShowing: Bool = false
    // Toast type
    var toastType: ToastType = .toast
    // Toast title
    var title: String?
    // Toast content
    var message: String?
    // Background color
    var bgColor: Color?
    // Toast disappear duration
    var duration: TimeInterval = 2
    // Animation duration
    private var animationDuration: TimeInterval = 0.2
    
    var onCancel: (@Sendable () -> Void)?
    
    init(
        isShowing: Bool = false,
        toastType: ToastType = .loading,
        title: String? = nil,
        message: String? = nil,
        bgColor: Color? = .reverseBackground,
        duration: TimeInterval = 2
    ) {
        self.isShowing = isShowing
        self.toastType = toastType
        self.title = title
        self.message = message
        self.bgColor = bgColor
        self.duration = duration
    }
    
    func showLoading(
        title: String? = nil,
        message: String? = nil,
        onCancel: (@Sendable () -> Void)? = nil
    ) {
        self.isShowing = true
        self.toastType = .loading
        
        self.title = title
        self.message = message
        self.onCancel = onCancel
    }
    
    func dismissLoading() {
        self.duration = 2
        self.isShowing = false
    }
    
    func showToast(
        title: String? = nil,
        message: String? = nil,
        duration: TimeInterval = 2,
        completion: (@Sendable () -> Void)? = nil
    ) {
        self.isShowing = true
        self.toastType = .toast
        
        self.title = title
        self.message = message
        self.bgColor = bgColor
        self.duration = duration
        
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.isShowing = false
                completion?()
            }
        }
    }
}

struct ToastContentView: View {
    @Environment(ToastViewObserver.self) var toastViewObserver
    @State private var isCancelVisible = false
    @State private var cancelButtonTask: Task<Void, Never>?
    
    let timeOfCancel: TimeInterval = 30
    
    var body: some View {
        if toastViewObserver.isShowing {
            ZStack {
                if let bgColor = toastViewObserver.bgColor {
                    Color(bgColor)
                        .opacity(0.2)
                        .edgesIgnoringSafeArea(.all)
                }
                
                if toastViewObserver.toastType == .loading {
                    // Show loading indicator
                    VStack(spacing: 30) {
                        VStack {
                            // Indicator
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(2)
                                .tint(.secondaryText)
                                .padding(20)
                                .shadow(radius: 1)
                            
                            // Title
                            if let title = toastViewObserver.title, !title.isEmpty {
                                Text(title)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.mainTheme)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Message content
                            if let message = toastViewObserver.message, !message.isEmpty {
                                Text(message)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primaryText)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                                    .padding()
                                    .background(
                                        Capsule()
                                            .fill(Color.secondary.opacity(0.1))
                                    )
                            }
                        }
                        .padding()
                        .padding(.vertical)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.secondaryBackground)
                        )
                        .padding()
                        .padding(.horizontal)
                        
                        if isCancelVisible {
                            Button {
                                toastViewObserver.onCancel?()
                                toastViewObserver.dismissLoading()
                            } label: {
                                HStack {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .scaledToFit()
                                        .font(.headline)
                                        .foregroundStyle(.reversePrimaryText)
                                        .frame(width: 18, height: 18)
                                    
                                    Text("Cancel")
                                        .font(.headline)
                                        .foregroundStyle(.reversePrimaryText)
                                }
                                .padding()
                                .padding(.horizontal)
                                .background(
                                    Capsule()
                                        .fill(.reverseBackground.opacity(0.6))
                                )
                            }
                            .withPressableButtonStyle()
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .onAppear {
                        startCancelButtonTimer()
                    }
                    .onDisappear {
                        resetCancelButtonTimer()
                    }
                }
//                else if toastViewObserver.toastType == .toast {
//                    if let message = toastViewObserver.message, let imageName = toastViewObserver.imageName {
//                        // Show toast with text and image
//                        VStack {
//                            Image(imageName)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 60, height: 60)
//                                .cornerRadius(10)
//                            
//                            Text(message)
//                                .font(.system(size: toastViewObserver.fontSize))
//                                .foregroundColor(.white)
//                                .lineLimit(nil)
//                        }
//                        .padding(10)
//                        .background(toastViewObserver.bgColor)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                        .shadow(radius: 3)
//
////                        .padding(20)
//                    } else {
//                        if let message = toastViewObserver.message {
//                            // Show toast with text only
//                            Text(message)
//                                .font(.system(size: toastViewObserver.fontSize))
//                                .lineLimit(nil)
//                                .padding(10)
//                                .foregroundColor(.white)
//                                .background(toastViewObserver.bgColor)
//                                .clipShape(RoundedRectangle(cornerRadius: 10))
//                                .shadow(radius: 3)
//                                .padding(.horizontal, 30)
//                        } else if let imageName = toastViewObserver.imageName {
//                            // Show toast with image only
//                            Image(imageName)
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 60, height: 60)
//                                .cornerRadius(10)
//                                .padding()
//                        }
//                    }
//                }
            }
        }
        //        .background(.black)
        //        .cornerRadius(10)
    }
    
    private func startCancelButtonTimer() {
        resetCancelButtonTimer()
        
        cancelButtonTask = Task {
            try? await Task.sleep(for: .seconds(timeOfCancel))
            guard !Task.isCancelled else { return }
            
            withAnimation {
                isCancelVisible = true
            }
        }
    }
    
    private func resetCancelButtonTimer() {
        cancelButtonTask?.cancel()
        cancelButtonTask = nil
        isCancelVisible = false
    }
}

struct ToastViewModifier: ViewModifier {
    @Environment(ToastViewObserver.self) var toastViewObserver
    
    // Customized view to show toast
    var customView: AnyView
    // Transition when show toast
    var transition: AnyTransition
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: toastViewObserver.isShowing ? 6.0 : 0.0)
                .disabled(toastViewObserver.isShowing ? true : false)
            
            customView
                .transition(transition)
        }
    }
}

extension View {
    func toastView(toastViewObserver: ToastViewObserver) -> some View {
        self.modifier(ToastViewModifier(customView: AnyView(ToastContentView()), transition: .opacity))
            .onDisappear() {
                toastViewObserver.dismissLoading()
            }
    }
}


#Preview("Loading") {
    ToastContentView()
        .environment(ToastViewObserver(isShowing: true, toastType: .loading, title: "PROCESSING...", message: "Preparing your personalized experience..."))
}
