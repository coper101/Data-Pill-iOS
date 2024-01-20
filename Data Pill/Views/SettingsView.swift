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
    var atTop: Bool
    var alignment: HorizontalAlignment
    
    // MARK: UI
    var header: some View {
        Text(title.uppercased())
            .textStyle(
                foregroundColor: .onSurfaceLight,
                size: 14
            )
    }
    
    func body(content: Content) -> some View {
        VStack(alignment: alignment, spacing: 12) {
            
            // MARK: HEADER (TOP)
            if atTop {
                
                header
                
            } //: if
            
            // MARK: CONTENT
            content
            
            // MARK: HEADER (BOTTOM)
            if !atTop {
                
                header
                
            } //: if
            
        } //: VStack
    }
}

extension View {
    
    func section(
        title: String,
        atTop: Bool = true,
        alignment: HorizontalAlignment = .leading
    ) -> some View {
        self.modifier(
            SectionModifier(
                title: title,
                atTop: atTop,
                alignment: alignment
            )
        )
    }
    
    func rowSection(title: String) -> some View {
        self
            .background(Colors.surface.color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .section(title: title )
    }
}

struct SettingsView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    
    @State private var isDarkMode: Bool = true
    @State private var isNotificationOn: Bool = true
    
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
                            isOn: $isDarkMode
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
            case .showAllRecords:
                ShowAllRecordsView()
            case .reportABug:
                ReportABugView()
            case .requestAFeature:
                RequestAFeatureView()
            case .none:
                root
            } //: switch-case
                        
        } //: VStack
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
