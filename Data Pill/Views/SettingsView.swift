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
    var root: some View {
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
                    
                    SettingsRowView(
                        title: "Customize Pill",
                        icon: .pillIcon,
                        iconColor: .secondaryPurple,
                        action: { screenAction(screen: .customizePill) }
                    ) {
                        
                    } //: SettingsRowView
                    
                } //: VStack
                .rowSection(title: "Appearance")
                
                // MARK: - NOTIFICATION
                VStack(spacing: 0) {
                    
                    SettingsRowView(
                        title: "Notifications",
                        subtitle: notificationSubtitle,
                        icon: .bellIcon,
                        iconColor: .secondaryOrange,
                        action: { screenAction(screen: .notifications) }
                    ) {
                        
                    } //: SettingsRowView
                    
                } //: VStack
                .rowSection(title: "Notification")
                
                // MARK: - DATA
                VStack(spacing: 0) {
                    
                    SettingsRowView(
                        title: "Show All Records",
                        icon: .fileIcon,
                        iconColor: .secondaryGreen,
                        action: { screenAction(screen: .showAllRecords) }
                    ) {
                        
                    } //: SettingsRowView
                    
                } //: VStack
                .rowSection(title: "data")
                
                // MARK: - SUPPORT
                VStack(spacing: 0) {
                    
                    SettingsRowView(
                        title: "Report a Bug",
                        icon: .bugIcon,
                        iconColor: .secondaryRed,
                        hasDivider: true,
                        action: { screenAction(screen: .reportABug) }
                    ) {
                        
                    } //: SettingsRowView
                    
                    SettingsRowView(
                        title: "Request a Feature",
                        icon: .starIcon,
                        iconColor: .secondaryRed,
                        action: { screenAction(screen: .requestAFeature) }
                    ) {
                        
                    } //: SettingsRowView
                    
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
        VStack(spacing: 0) {
            
            // MARK: TOP BAR
            if let settingsScreen = appViewModel.activeSettingsScreen {
                
                HStack(spacing: 0) {
                    
                    // MARK: Back
                    Button(action: backAction) {
                        
                        Icons.navigateIcon.image
                            .resizable()
                            .rotationEffect(.degrees(180))
                            .frame(width: 38, height: 38)
                            .foregroundColor(Colors.secondaryBlue.color)
                    } //: Button
                    
                    // MARK: Title
                    Spacer()
                    Text(settingsScreen.title)
                        .textStyle(
                            foregroundColor: .onBackground,
                            size: 18
                        )
                    
                    // MARK: Filler
                    Spacer()
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 38, height: 38)
                    
                } //: HStack
                .frame(height: 58)
                .overlay(
                    DividerView(
                        color: .onBackgroundLight,
                        height: 0.2
                    ),
                    alignment: .bottom
                )
                
            } //: if
            
            // MARK: ROOT
            switch appViewModel.activeSettingsScreen {
            case .customizePill:
                CustomizePillView()
            case .notifications:
                NotificationSettingsView()
            case .showAllRecords:
                ShowAllRecordsView()
            case .reportABug:
                ReportABugView(viewModel: .init())
            case .requestAFeature:
                RequestAFeatureView()
            case .none:
                root
            } //: switch-case
                        
        } //: VStack
        .padding(.top, dimensions.insets.top)
        .background(Colors.background.color)
        .ignoresSafeArea()
        .preferredColorScheme(appViewModel.colorScheme)
    }
    
    // MARK: - Actions
    func backAction() {
        withAnimation {
            appViewModel.didTapBackSettingsChild()
        }
    }
    
    func screenAction(screen: SettingsScreen) {
        withAnimation {
            appViewModel.didTapSettingsChild(screen: screen)
        }
    }
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
