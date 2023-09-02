//
//  Data_PillApp.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

@main
struct Data_PillApp: App {
    // MARK: - Props
    @StateObject var appViewModel: AppViewModel = {
        if ProcessInfo.isUITesting && ProcessInfo.isMockedCloudAndMobileData {
            return .init(
                dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: MockCloudDatabase()),
                networkDataRepository: MockNetworkDataRepository(automaticUpdates: true)
            )
        } //: if
        return .init()
    }()
    
    // MARK: - UI
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.isRunningUnitTests {
                
                EmptyView()
                
            } else {
                
                AppView()
                    .environmentObject(appViewModel)
                
            } //: if-else
        }
    }
}
