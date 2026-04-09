//
//  CustomAlertModifier.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 07/04/2026.
//

import SwiftUI

struct CustomAlertModifier<AlertContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let isDismissable: Bool
    let alertContent: () -> AlertContent
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isPresented ? 6.0 : 0)
                .disabled(isPresented)
            
            if isPresented {
                Color.black
                    .opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if isDismissable {
                            isPresented = false
                        }
                    }
                
                alertContent()
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

extension View {
    func customAlert<AlertContent: View>(
        isPresented: Binding<Bool>,
        isDismissable: Bool = false,
        @ViewBuilder content: @escaping () -> AlertContent
    ) -> some View {
        modifier(CustomAlertModifier(isPresented: isPresented, isDismissable: isDismissable, alertContent: content))
    }
}

#Preview {
    VStack {
        Spacer()
        
        ForEach(1...5) { index in
            Text("Example: \(index)")
            
            Spacer()
        }
    }
    .customAlert(isPresented: .constant(true)) {
        VStack {
            Text("Alert title")
                .font(.title)
                .padding()
            
            Text("This is the detailed message of the alert. It could be a multiline message.")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.secondaryText)
                .multilineTextAlignment(.center)
                .padding()
            
            Button {
                
            } label: {
                Text("OK")
            }
            .padding()
            
            Button {
                
            } label: {
                Text("Cancel")
            }
            .padding(.bottom)
        }
        .background(
            RoundedRectangle(cornerRadius: 20.0)
                .fill(.white)
        )
        .padding()
    }
}
