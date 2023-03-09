//
//  SyncIndicatorView.swift
//  Data Pill
//
//  Created by Wind Versi on 5/3/23.
//

import SwiftUI

struct SyncIndicatorView: View {
    // MARK: - Props
    var isSyncing: Bool
    
    // MARK: - UI
    var body: some View {
        HStack(spacing: 16) {
            
            if isSyncing {
                
                Group {
                    
                    SpinnerView()
                        .fadeInOut()
                    
                    Text("iCloud")
                        .textStyle(
                            foregroundColor: .onSurfaceLight,
                            font: .semibold,
                            size: 16
                        )
                        .fadeInOut()
                    
                } //: Group
                .transition(.slide.animation(.easeIn(duration: 0.5)))
                                
            } else {
                
                Text("Synced")
                    .textStyle(
                        foregroundColor: .onSurfaceLight2,
                        font: .semibold,
                        size: 16
                    )
                    .fadeInOut()
                
            } //: if-else
            
            Spacer()
            
        } //: HStack
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct SyncIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        SyncIndicatorView(isSyncing: true)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Syncing")
        
        SyncIndicatorView(isSyncing: false)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Synced")
    }
}
