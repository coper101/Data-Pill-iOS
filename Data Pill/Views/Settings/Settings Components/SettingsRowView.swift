//
//  SettingsRowView.swift
//  Data Pill
//
//  Created by Wind Versi on 17/1/24.
//

import SwiftUI

struct SettingsRowView<Content>: View where Content: View {
    // MARK: - Props
    var title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    var icon: Icons?
    var iconColor: Colors?
    var hasDivider: Bool = false
    var action: Action?
    @ViewBuilder var trailingContent: Content
    
    // MARK: - UI
    var content: some View {
        HStack(spacing: 14) {
            
            // MARK: ICON
            if let icon, let iconColor {
                
                Circle()
                    .fill(iconColor.color)
                    .frame(width: 32, height: 32)
                    .overlay(
                        icon.image
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Colors.background.color)
                    )
            } //: if
            
            // MARK: TITLE
            VStack(
                alignment: .leading,
                spacing: (subtitle == nil) ? 0 : 3
            ) {
                
                Text(title)
                    .textStyle(
                        foregroundColor: .onSurface,
                        size: 16
                    )
                
                if let subtitle {
                    
                    Text(subtitle)
                        .textStyle(
                            foregroundColor: .onSurfaceLight,
                            size: 13
                        )
                    
                } //: if
            }
            
            Spacer()
            
            // MARK: CONTENT
            if action == nil {
                
                trailingContent
                
            } else {
                
                Icons.navigateThickIcon.image
                    .resizable()
                    .frame(width: 26, height: 26)
                    .foregroundColor(Colors.onSurfaceLight.color)
                
            } //: if-else
            
        } //: HStack
        .padding(.leading, 16)
        .padding(.trailing, (action == nil) ? 21 : 10)
        .padding(.vertical, 12)
    }
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: CONTENT
            content
                
            // MARK: DIVIDER
            if hasDivider {
                
                DividerView(color: .onSurfaceLight2)
                    .padding(.leading, (icon != nil) ? 58 : 18)
                    .padding(.trailing, 18)
                
            } //: if
            
        } //: VStack
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct SettingsRowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            SettingsRowView(
                title: "Dark Mode",
                subtitle: "Subtitle",
                icon: .moonIcon,
                iconColor: .secondaryPurple,
                hasDivider: true
            ) { Text("Content") }
            .previewDisplayName("w/o Action")
            
            SettingsRowView(
                title: "Dark Mode",
                subtitle: "Subtitle",
                hasDivider: true
            ) { Text("Content") }
            .previewDisplayName("w/o Icon")
            
            SettingsRowView(
                title: "Dark Mode",
                icon: .moonIcon,
                iconColor: .secondaryPurple,
                hasDivider: true,
                action: {}
            ) { Text("Content") }
            .previewDisplayName("w/ Action")

        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
