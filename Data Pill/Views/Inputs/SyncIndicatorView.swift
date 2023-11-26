//
//  SyncIndicatorView.swift
//  Data Pill
//
//  Created by Wind Versi on 5/3/23.
//

import SwiftUI

enum SyncStatus {
    case syncing(message: String)
    case synced
    case failed(message: String)
}

struct SyncIndicatorView: View {
    // MARK: - Props
    var status: SyncStatus
    
    // MARK: - UI
    func syncing(_ message: String) -> some View {
        Group {
            
            SpinnerView()
                .fadeInOut()
            
            Text(message)
                .textStyle(
                    foregroundColor: .onSurfaceLight,
                    font: .semibold,
                    size: 16
                )
                .fadeInOut()
            
        } //: Group
        .transition(.slide.animation(.easeIn(duration: 0.5)))
    }
    
    var synced: some View {
        Text("Synced")
            .textStyle(
                foregroundColor: .onSurfaceLight,
                font: .semibold,
                size: 16
            )
            .fadeInOut()
    }
    
    func failed(_ message: String) -> some View {
        Text(message)
            .textStyle(
                foregroundColor: .onSurfaceLight,
                font: .semibold,
                size: 16
            )
            .fadeInOut()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            
            switch status {
            case .syncing(let message):
                syncing(message)
            case .synced:
                synced
            case .failed(let message):
                failed(message)
            }
            
            Spacer()
            
        } //: HStack
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct SyncIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        SyncIndicatorView(status: SyncStatus.syncing(message: "Syncing 10 Items to iCloud"))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Syncing")
        
        SyncIndicatorView(status: SyncStatus.synced)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Synced")
        
        SyncIndicatorView(status: SyncStatus.failed(message: "Unable to Sync"))
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Failed")
    }
}
