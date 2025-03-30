//
//  SettingListItem.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 30/03/2025.
//

import SwiftUI

struct SettingListItem: View {
    let setting: SettingModel
    
    var body: some View {
        var timeComponent = (setting.startTime ?? "").split(separator: ":")
        timeComponent.removeLast()
        let startTime = timeComponent.joined(separator: ":")
        
        timeComponent = (setting.endTime ?? "").split(separator: ":")
        timeComponent.removeLast()
        let endTime = timeComponent.joined(separator: ":")
        
        return VStack {
            HStack {
                Text("Distance Filter: ")
                    .fontWeight(.bold)
                
                Text("\(setting.distanceFilter ?? 0)")
                
                Spacer()
            }
            
            HStack {
                Text("Accuracy: ")
                    .fontWeight(.bold)
                
                Text("\(setting.accuracy ?? "")")
                
                Spacer()
            }
            
            HStack {
                Text("Effective Range: ")
                    .fontWeight(.bold)
                
                Text("\(startTime) - \(endTime)")
                
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    Group {
        SettingListItem(setting: mockSetting1)
        SettingListItem(setting: mockSetting2)
    }
}
