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
    
    let localNotificationManager: LocalNotificationManager = .shared
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        localNotificationManager.notificationCenter.delegate = self
        
        /// Disable iCloud for now
        // UIApplication.shared.registerForRemoteNotifications()
        // Logger.appDelegate.debug("- REMOTE NOTIFICATION: 💈 \(UIApplication.shared.isRegisteredForRemoteNotifications ? "Registered" : "Not Registered")")
        return true
    }
    
    // func application(
    //     _ application: UIApplication,
    //     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    //     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    // ) {
    //     Logger.appDelegate.debug("- REMOTE NOTIFICATION: 💈 Received")
    //
    //     guard
    //         let notification = CKNotification(fromRemoteNotificationDictionary: userInfo),
    //         let subscriptionID =  notification.subscriptionID,
    //         let remoteSubscription = RemoteSubscription(rawValue: subscriptionID)
    //     else {
    //         return
    //     }
    //
    //     switch remoteSubscription {
    //     case .plan:
    //         NotificationCenter.default.post(name: .plan, object: nil)
    //     case .todaysData:
    //         NotificationCenter.default.post(name: .todaysData, object: nil)
    //     }
    //
    //     completionHandler(.newData)
    // }
    
    // private func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    //     /// Note: Most of the time, this method is not called
    //     Logger.appDelegate.debug("- REMOTE NOTIFICATION: 💈 Registered")
    // }
    
    // func application(
    //     _ application: UIApplication,
    //     didFailToRegisterForRemoteNotificationsWithError error: Error
    // ) {
    //     /// Note: Most of the time, this method is not called
    //     Logger.appDelegate.debug("- APP DELEGATE: ℹ️ Failed to Register | REASON: \(error.localizedDescription)")
    // }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// Handler when app is in background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let identifier = response.notification.request.identifier
        guard let notification = NotificationItem(rawValue: identifier) else {
            return
        }
        localNotificationManager.resetReceivedNotification(notification: notification)
    }
    
    /// Notiifcation alert types
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .badge, .sound])
    }
}
