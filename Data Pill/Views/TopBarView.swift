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
    
    // MARK: - UI
    var body: some View {
        HStack(spacing: 0) {
            
            SyncIndicatorView(status: syncStatus)
            
            Spacer()
            
        } //: HStack
        .frame(height: dimensions.topBarHeight)
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView(syncStatus: .synced)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
