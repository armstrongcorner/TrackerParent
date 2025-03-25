//
//  DateRangePickerView.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/24.
//

import SwiftUI

struct DateRangePickerView: View {
    @Binding var bindingStartDate: Date
    @Binding var bindingEndDate: Date
    @State var startDate: Date
    @State var endDate: Date
    
    init(bindingStartDate: Binding<Date>, bindingEndDate: Binding<Date>) {
        self._bindingStartDate = bindingStartDate
        self._bindingEndDate = bindingEndDate
        self.startDate = bindingStartDate.wrappedValue
        self.endDate = bindingEndDate.wrappedValue
    }
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Select Date Range")
                .font(.system(size: 28))
                .fontWeight(.semibold)
                .padding(.top, 20)
                .padding(.bottom, 30)
            
            DatePicker(selection: $startDate, in: ...endDate, displayedComponents: .date) {
                Text("Start Date")
            }
            .tint(.black)
            
            DatePicker(selection: $endDate, in: startDate..., displayedComponents: .date) {
                Text("End Date")
            }
            .tint(.black)
            
            Button {
                // Confirm to bind the date back
                bindingStartDate = startDate
                bindingEndDate = endDate
                
                dismiss()
            } label: {
                Text("Confirm")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 180, height: 45)
                    .background(.blue)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .padding(.top, 60)
            
            Spacer()
        }
        .padding(.horizontal, 30)
        .background(Color.gray.opacity(0.12))
    }
}

#Preview {
    DateRangePickerView(
        bindingStartDate: Binding(get: {
            Date.now
        }, set: { _ in
            
        }),
        bindingEndDate: Binding(get: {
            Date.now
        }, set: { _ in
            
        })
    )
}
