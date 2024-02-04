//
//  NotificationSettingsView.swift
//  Data Pill
//
//  Created by Wind Versi on 28/1/24.
//

import SwiftUI

struct NotificationSettingsView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    
    // MARK: - UI
    var body: some View {
        ScrollView {
            
            VStack(spacing: 34) {
                                
                SettingsRowView(title: "Exceeds 90% of Limit") {
                    
                    SlideToggleView(
                        activeColor: .secondaryBlue,
                        isOn: $appViewModel.hasDailyNotification
                    )
                    .padding(.vertical, 4)
                    
                }
                .rowSection(title: "Daily Usage")
                
                SettingsRowView(title: "Exceeds 100% of Limit") {
                    
                    SlideToggleView(
                        activeColor: .secondaryBlue,
                        isOn: $appViewModel.hasPlanNotification
                    )
                    .padding(.vertical, 4)
                    
                }
                .rowSection(title: "Plan Usage")
                
            } //: VStack
            .padding(.horizontal, 24)
            .padding(.top, 21)
            
        } //: ScrollView
        .withTopBar(title: "Notifications")
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
            .previewLayout(.sizeThatFits)
            .background(Colors.background.color)
            .environmentObject(TestData.createAppViewModel())
    }
}
