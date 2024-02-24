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
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    @StateObject var appViewModel: AppViewModel
    @StateObject var localNotificationManager: LocalNotificationManager
    
    init() {
        
        let localNotificationManager = LocalNotificationManager.shared
        _localNotificationManager = .init(wrappedValue: localNotificationManager)
        
        let appViewModel = Self.createAppViewModel()
        _appViewModel = .init(wrappedValue: appViewModel)
    }
    
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

extension Data_PillApp {
    
    static func createAppViewModel() -> AppViewModel {
        if !ProcessInfo.isUITesting {
            return .init()
        }
        
        /// * UI Testing *
        if ProcessInfo.isMockedCloud && ProcessInfo.isMockedMobileData {
            return .init(
                dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: MockCloudDatabase()),
                networkDataRepository: MockNetworkDataRepository(automaticUpdates: true)
            )
        } else if ProcessInfo.isMockedCloud {
            return .init(
                dataUsageRemoteRepository: DataUsageRemoteRepository(remoteDatabase: MockCloudDatabase())
            )
        } else if ProcessInfo.isMockedMobileData {
            return .init(
                networkDataRepository: MockNetworkDataRepository(automaticUpdates: true)
            )
        } else {
            return .init()
        }
    }
}
