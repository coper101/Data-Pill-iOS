//
//  Data_PillApp.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

@main
struct Data_PillApp: App {
    var appState: AppState = .init()
    
    init() {
        print(appState)
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(appState)
        }
    }
}
