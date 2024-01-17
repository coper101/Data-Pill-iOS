//
//  SettingsView.swift
//  Data Pill
//
//  Created by Wind Versi on 13/1/24.
//

import SwiftUI

struct SectionModifier: ViewModifier {
    // MARK: Props
    var title: String
    
    // MARK: UI
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            
            Text(title.uppercased())
                .textStyle(
                    foregroundColor: .onSurfaceLight,
                    size: 14
                )
            
            content
                .background(Colors.surface.color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
        } //: VStack
    }
}

extension View {
    
    func section(title: String) -> some View {
        self.modifier(SectionModifier(title: title))
    }
}

struct SettingsView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    
    @State private var isDarkMode: Bool = true
    @State private var isNotificationOn: Bool = true
    
    // MARK: - UI
    var body: some View {
        NavigationView {
            
            // MARK: ROOT
            ScrollView {
                
                VStack(spacing: 26) {
                    
                    // MARK: APPEARANCE
                    VStack(spacing: 0) {
                        
                        SettingsRowView(
                            title: "Dark Mode",
                            icon: .moonIcon,
                            iconColor: .secondaryPurple,
                            hasDivider: true
                        ) {
                            
                            SlideToggleView(
                                activeColor: .secondaryBlue,
                                isOn: $isDarkMode
                            )
                            
                        } //: SettingsRowView
                        
                        SettingsRowView(
                            title: "Customize Pill",
                            icon: .pillIcon,
                            iconColor: .secondaryPurple,
                            action: {}
                        ) {
                            
                            SlideToggleView(
                                activeColor: .secondaryBlue,
                                isOn: $isDarkMode
                            )
                            
                        } //: SettingsRowView
                        
                    } //: VStack
                    .section(title: "Appearance")
                    
                    // MARK: NOTIFICATION
                    VStack(spacing: 0) {
                        
                        SettingsRowView(
                            title: "Notify",
                            subtitle: "On Exceeds Limit",
                            icon: .bellIcon,
                            iconColor: .secondaryOrange
                        ) {
                            
                            SlideToggleView(
                                activeColor: .secondaryBlue,
                                isOn: $isNotificationOn
                            )
                            
                        } //: SettingsRowView
                        
                    } //: VStack
                    .section(title: "Notification")
                    
                    // MARK: DATA
                    VStack(spacing: 0) {
                        
                        SettingsRowView(
                            title: "Show All Records",
                            icon: .fileIcon,
                            iconColor: .secondaryGreen,
                            action: {}
                        ) {
                            
                        } //: SettingsRowView
                        
                    } //: VStack
                    .section(title: "data")
                    
                    // MARK: SUPPORT
                    VStack(spacing: 0) {
                        
                        SettingsRowView(
                            title: "Report a Bug",
                            icon: .bugIcon,
                            iconColor: .secondaryRed,
                            hasDivider: true,
                            action: {}
                        ) {
                            
                        } //: SettingsRowView
                        
                        SettingsRowView(
                            title: "Request a Feature",
                            icon: .starIcon,
                            iconColor: .secondaryRed,
                            action: {}
                        ) {
                            
                        } //: SettingsRowView
                        
                    } //: VStack
                    .section(title: "Support")

                } //: VStack
                .padding(.horizontal, 21)
                .padding(.vertical, 12)
              
            } //: VStack
            .fillMaxSize()
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var appViewModel = TestData.createAppViewModel()

    static var previews: some View {
        SettingsView()
            .environmentObject(appViewModel)
    }
}
