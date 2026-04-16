//
//  TuppView.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 14/04/2026.
//

import SwiftUI

struct TuppView: View {
    var body: some View {
        // Terms of use and privacy policy
        HStack {
            Button {
                
            } label: {
                Text("Terms of Use")
                    .font(.subheadline)
                    .foregroundStyle(.secondaryText)
                    .underline()
            }
            
            Text("")
                .padding(2)
                .background(
                    Circle()
                        .fill(.secondaryText)
                )
            
            Button {
                
            } label: {
                Text("Privacy Policy")
                    .font(.subheadline)
                    .foregroundStyle(.secondaryText)
                    .underline()
            }
        }
    }
}

#Preview {
    TuppView()
}
