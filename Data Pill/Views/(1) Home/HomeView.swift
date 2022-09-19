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
        VStack(spacing: 0) {
            
            HStack(spacing: spaceInBetween) {
                
                // Col 1: DATA PILL
                PillView(
                    color: .secondaryBlue,
                    percentage: 20,
                    date: appState.data[6].date
                )
                
                // Col 2: INFO & CONTROLS
                GeometryReader { reader in
                    
                    let cardWidth = reader.size.width - paddingHorizontal - spaceInBetween
                    
                    VStack(spacing: spaceInBetween) {
                        
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
            
            
        } //: VStack
        .padding(.horizontal, paddingHorizontal)
        .fillMaxSize()
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
