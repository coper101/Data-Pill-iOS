//
//  SettingsView.swift
//  Data Pill
//
//  Created by Wind Versi on 13/1/24.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dimensions) var dimensions: Dimensions
    
    var notificationSubtitle: String? {
        let hasDailyNotif = appViewModel.hasDailyNotification
        let hasPlanNotif = appViewModel.hasPlanNotification
        if hasDailyNotif && hasPlanNotif {
            return "Daily Usage, Plan Usage"
        } else if hasDailyNotif {
            return "Daily Usage"
        } else if hasPlanNotif {
            return "Plan Usage"
        } else {
            return nil
        }
    }

    // MARK: - UI
    var content: some View {
        ScrollView {
            
            HStack(spacing: 0) {
                
                // MARK: Title
                Text("Settings")
                    .textStyle(
                        foregroundColor: .onBackground,
                        font: .bold,
                        size: 32
                    )
                
                Spacer()
                
                // MARK: Close
                CloseIconView(action: appViewModel.closeSettings)
                
            } //: HStack
            .padding(.leading, 18)
            .padding(.trailing, 12)
            .padding(.top, 21)
            
            VStack(spacing: 26) {
                
                // MARK: - APPEARANCE
                VStack(spacing: 0) {
                    
                    SettingsRowView(
                        title: "Dark Mode",
                        icon: .moonIcon,
                        iconColor: .secondaryPurple,
                        hasDivider: true
                    ) {
                        
                        SlideToggleView(
                            activeColor: .secondaryBlue,
                            isOn: $appViewModel.isDarkMode
                        )
                        
                    } //: SettingsRowView
                    
                    NavigationLink(destination: CustomizePillView()) {
                        
                        SettingsRowView(
                            title: "Customize Pill",
                            icon: .pillIcon,
                            iconColor: .secondaryPurple,
                            action: {}
                        ) {
                            
                        } //: SettingsRowView
                        
                    }

                } //: VStack
                .rowSection(title: "Appearance")
                
                // MARK: - NOTIFICATION
                VStack(spacing: 0) {
                    
                    NavigationLink(destination: NotificationSettingsView()) {
                        
                        SettingsRowView(
                            title: "Notifications",
                            subtitle: notificationSubtitle,
                            icon: .bellIcon,
                            iconColor: .secondaryOrange,
                            action: {}
                        ) {
                            
                        } //: SettingsRowView
                        
                    }
                    
                } //: VStack
                .rowSection(title: "Notification")
                
                // MARK: - DATA
                VStack(spacing: 0) {
                    
                    NavigationLink(destination: ShowAllRecordsView()) {
                        
                        SettingsRowView(
                            title: "Show All Records",
                            icon: .fileIcon,
                            iconColor: .secondaryGreen,
                            hasDivider: true,
                            action: {}
                        ) {
                            
                        } //: SettingsRowView
                        
                    }
                    
                    NavigationLink(destination: EditDataUnitView()) {
                        
                        SettingsRowView(
                            title: "Data Unit",
                            icon: .dataPacket,
                            iconColor: .secondaryGreen,
                            action: {}
                        ) {
                            
                        } //: SettingsRowView
                        
                    }
                    
                } //: VStack
                .rowSection(title: "data")
                
                // MARK: - SUPPORT
                VStack(spacing: 0) {
                    
                    NavigationLink(destination: ReportABugView()) {
                        
                        SettingsRowView(
                            title: "Report a Bug",
                            icon: .bugIcon,
                            iconColor: .secondaryRed,
                            hasDivider: true,
                            action: {}
                        ) {
                            
                        } //: SettingsRowView
                    }
                    
                    NavigationLink(destination: RequestAFeatureView()) {
                        
                        SettingsRowView(
                            title: "Request a Feature",
                            icon: .starIcon,
                            iconColor: .secondaryRed,
                            action: {}
                        ) {
                            
                        } //: SettingsRowView
                    }
                    
                } //: VStack
                .rowSection(title: "Support")

            } //: VStack
            .padding(.horizontal, 21)
            .padding(.top, 4)
            .padding(.bottom, 16)
          
        } //: ScrollView
        .fillMaxSize()
    }
    
    var body: some View {
        NavigationView {
            
            content
                .hideNavigationBar()
                .padding(.top, dimensions.insets.top)
                .background(Colors.background.color)
                .ignoresSafeArea(.container, edges: .vertical)
                .preferredColorScheme(appViewModel.colorScheme)
        } //: NavigationView
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(TestData.createAppViewModel())
            .previewDisplayName("Root")
        
        ForEach(SettingsScreen.allCases) { screen in
            SettingsView()
                .environmentObject(TestData.createAppViewModel(activeSettingsScreen: screen))
                .previewDisplayName(screen.title)
        }
    }
}
