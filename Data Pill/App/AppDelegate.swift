//
//  AppDelegate.swift
//  Data Pill
//
//  Created by Wind Versi on 23/2/23.
//

import SwiftUI
import CloudKit
import OSLog

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        Logger.appDelegate.debug("- APP DELEGATE: ℹ️ Received Remote Notification")
        
        guard
            let notification = CKNotification(fromRemoteNotificationDictionary: userInfo),
            let subscriptionID =  notification.subscriptionID,
            let remoteSubscription = RemoteSubscription(rawValue: subscriptionID)
        else {
            return
        }
        
        switch remoteSubscription {
        case .plan:
            NotificationCenter.default.post(name: .plan, object: nil)
        case .todaysData:
            NotificationCenter.default.post(name: .todaysData, object: nil)
        }
        
        completionHandler(.newData)
    }
    
    private func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Logger.appDelegate.debug("- APP DELEGATE: ℹ️ Registered for Remote Notifications with Device Token")
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Logger.appDelegate.debug("- APP DELEGATE: ℹ️ Failed to Register Remote Notification with Error: \(error.localizedDescription)")
    }
}
