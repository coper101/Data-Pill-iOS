//
//  Data_PillApp.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

enum Screen {
    case guide
    case overview
}

@main
struct Data_PillApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(appViewModel)
                .background(Colors.background.color)
                .sheet(
                    isPresented: $appViewModel.isGuideShown,
                    onDismiss: {}
                ) {
                    GuideView()
                        .environmentObject(appViewModel)
                }
                .onAppear {
                    appViewModel.showGuide()
                }
        }
    }
}
