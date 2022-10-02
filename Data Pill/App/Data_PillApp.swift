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
    var dataModelRepo: DataModelRepository = .init()
    var networkDataRepo: NetworkDataRepository = .init()
    
    init() {
        print(appState)
        print(networkDataRepo)
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(appState)
                .environmentObject(dataModelRepo)
                .environmentObject(networkDataRepo)
        }
    }
}
