//
//  TrackListItem.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 2025/3/20.
//

import SwiftUI

struct TrackListItem: View {
    let track: [LocationModel]
    
    var body: some View {
        VStack {
            HStack {
                track.count > 1
                ? Text("ID: \(track.first?.id ?? 0) - \(track.last?.id ?? 0)")
                : Text("ID: \(track.first?.id ?? 0)")
                
                Spacer()
            }
            
            HStack {
                Text("Count: \(track.count)")
                
                Spacer()
            }
            
            HStack {
                Text("Time from: \(DateUtil.shared.convertStandardDateTimeStr(iso8601String: track.first?.createdDateTime ?? "") ?? "")")
                
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    TrackListItem(track: [])
}
