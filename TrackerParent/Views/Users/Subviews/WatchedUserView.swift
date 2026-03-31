//
//  WatchedUserView.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 30/03/2026.
//

import SwiftUI

struct WatchedUserView: View {
    let watchRelationship: WatchRelationshipModel
    let isSelected: Bool
    
    init(_ watchRelationship: WatchRelationshipModel, isSelected: Bool = false) {
        self.watchRelationship = watchRelationship
        self.isSelected = isSelected
    }
    
    var body: some View {
        let avatarColor = Color.color(for: watchRelationship.id == nil ? UUID().uuidString : String(watchRelationship.id ?? 0))
        
        VStack {
            HStack {
                // Avatar
                Text(StringUtil.shared.initials(from: (watchRelationship.watchedUser?.email ?? "")).uppercased())
                    .font(.title)
                    .fontWeight(.bold)
                    .padding([.vertical, .horizontal], 20)
                    .background(
                        Circle()
                            .fill(isSelected ? avatarColor.opacity(0.2) : .primaryText.opacity(0.45))
                    )
                    .overlay {
                        Circle()
                            .stroke(
                                isSelected ? .mainTheme.opacity(0.2) : .primaryText.opacity(0.1),
                                style: StrokeStyle(lineWidth: 2)
                            )
                    }
                    .padding(.trailing, 5)
                
                // Name & email
                VStack(alignment: .leading) {
                    Text(StringUtil.shared.name(from: watchRelationship.watchedUser?.email ?? ""))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(watchRelationship.watchedUser?.email ?? "")
                        .font(.callout)
                        .fontWeight(.regular)
                        .foregroundStyle(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            
            HStack {
                // Selection indicator text
                Text(isSelected ? "PRIMARY TRACK" : "STANDBY")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? .mainTheme : .primaryText.opacity(0.6))
                    .padding(.horizontal, 15)
                    .padding(.vertical, 5)
                    .background(isSelected ? .mainTheme.opacity(0.1) : .outline.opacity(0.5))
                    .clipShape(
                        Capsule()
                    )
                
                Spacer()
                
                // Selection indicator image
                isSelected ? Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.mainTheme)
                    .frame(width: 25, height: 25)
                : Image(systemName: "circle")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.outline.opacity(0.7))
                    .frame(width: 23, height: 23)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(isSelected ? .white : .outline.opacity(0.2))
        )
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        .mainTheme,
                        style: StrokeStyle(lineWidth: 1.5)
                    )
                    .shadow(color: .mainTheme, radius: 2, x: 0, y: 0)
            }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
        .listRowInsets(
            EdgeInsets(
                top: 6,
                leading: 0,
                bottom: 13,
                trailing: 0
            )
        )
    }
}

// MARK: - Previews
#Preview {
    Group {
        WatchedUserView(mockWatchRelationship1)
        WatchedUserView(mockWatchRelationship2, isSelected: true)
    }
}
