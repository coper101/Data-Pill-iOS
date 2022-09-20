//
//  HomeView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct HomeView: View {
    // MARK: - Props
    @EnvironmentObject var appState: AppState
    
    var spaceInBetween: CGFloat = 21
    var paddingHorizontal: CGFloat = 21
    
    // MARK: - UI
    var body: some View {
        ScrollView {
            
            VStack(spacing: spaceInBetween) {
                
                // MARK: - Row 1:
                HStack(
                    alignment: .top,
                    spacing: spaceInBetween
                ) {
                    
                    // Col 1: DATA PILL
                    PillView(
                        color: .secondaryBlue,
                        percentage: 20,
                        date: appState.data[6].date
                    )
                    
                    // Col 2: INFO & CONTROLS
                    GeometryReader { reader in
                        
                        let cardWidth = reader.size.width - paddingHorizontal - spaceInBetween
                        
                        VStack(spacing: spaceInBetween - 5) {
                            
                            // USED
                            UsedCardView(
                                width: cardWidth,
                                dataInMB: 130,
                                maxDataInMB: 300
                            )
                            
                            // USAGE TOGGLE
                            UsageCardView(
                                selectedItem: $appState.selectedItem,
                                width: cardWidth
                            )
                            
                            // NOTIF TOGGLE
                            NotifCardView(
                                isTurnedOn: $appState.isTurnedOn,
                                width: cardWidth
                            )
                            
                        } //: VStack
                        .fillMaxWidth()
                        
                    } //: GeometryReader
                    
                } //: HStack
                .frame(height: 388)
                
                // MARK: - Row 2:
                // DATA PLAN
                DataPlanCardView(
                    startDate: "2022-09-12T10:44:00+0000".toDate(),
                    endDate: "2022-10-12T10:44:00+0000".toDate(),
                    dataAmount: 10.0
                )
                
                // DATA LIMITS
                HStack(spacing: spaceInBetween) {
                    
                    DataPlanLimitView(dataLimitAmount: 9)
                    
                    DailyLimitView(dataLimitAmount: 300)
                    
                } //: HStack
                .frame(height: 145)
                
            } //: VStack
            .padding(.horizontal, paddingHorizontal)
            .padding(.vertical, paddingHorizontal)
            .fillMaxSize()
            
        } //: ScrollView
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .previewLayout(.sizeThatFits)
            .environmentObject(AppState())
    }
}
