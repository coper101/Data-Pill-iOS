//
//  TopBarView.swift
//  Data Pill
//
//  Created by Wind Versi on 5/3/23.
//

import SwiftUI

struct TopBarView: View {
    // MARK: - Props
    @Environment(\.dimensions) var dimensions
    var syncStatus: SyncStatus
    var settingsAction: Action
    
    // MARK: - UI
    var body: some View {
        HStack(spacing: 0) {
            
            /// Disable iCloud for now
            // SyncIndicatorView(status: syncStatus)
            
            Spacer()
            
            Button(action: settingsAction) {
                
                Icons.settingsIcon.image
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(Colors.onSurface.color)
                
            } //: Button
            
        } //: HStack
        .frame(height: dimensions.topBarHeight)
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView(
            syncStatus: .synced,
            settingsAction: {}
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
