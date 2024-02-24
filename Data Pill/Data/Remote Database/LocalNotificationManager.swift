//
//  LocalNotificationManager.swift
//  Data Pill
//
//  Created by Wind Versi on 27/1/24.
//

import UserNotifications
import OSLog
import SwiftUI

enum NotificationItem: String {
    case dailyUsage = "Daily_Usage"
    case planUsage = "Plan_Usage"
}

extension NotificationItem {
    
    var id: String {
       self.rawValue
    }
    
    var title: String {
        switch self {
        case .dailyUsage:
            return NSLocalizedString("⚠️ Daily Usage Limit Exceeded", comment: "")
        case .planUsage:
            return NSLocalizedString("❗️Data Plan Usage Limit Exceeded❗️", comment: "")
        }
    }
    
    func body(percentage: Int) -> String {
        switch self {
        case .dailyUsage:
            return .init(format: NSLocalizedString("You've used up %lld%% of your data today", comment: ""), percentage)
        case .planUsage:
            return NSLocalizedString("Please turn off mobile data now", comment: "")
        }
    }
}

// MARK: - Protocol
protocol LocalNotification {
    func requestPersmission() async -> Bool
    func status() async -> (isAllowed: Bool, isNotDetermined: Bool)
    func scheduleNow(notification: NotificationItem, amountUsageInPercentage: Int) async -> Void
    func removeAll() -> Void
    func hasReceived(notification: NotificationItem) async -> Bool
    func resetReceivedNotification(notification: NotificationItem) -> Void
}


// MARK: - App Implementation
final class LocalNotificationManager: ObservableObject, LocalNotification {
    
    // MARK: - Data
    @Published var isNotificationDelivered: NotificationItem?
    @Published var isDailyUsageRequested: Bool = false
    @Published var isPlanUsageRequested: Bool = false
    
    static var shared: LocalNotificationManager = {
        return .init()
    }()
    
    var notificationCenter: UNUserNotificationCenter {
        .current()
    }
    
    private init() {}
    
    // MARK: - Events
    
    // MARK: (1) Request, (2) Schedule
    func requestPersmission() async -> Bool {
        do {
            let options: UNAuthorizationOptions = [.alert, .sound, .badge]
            let result = try await notificationCenter.requestAuthorization(options: options)
            Logger.localNotification.debug("🔔 Permission Request: Success")
            return result
        } catch let error {
            Logger.localNotification.debug("🔔 Permission Request Error: \(error.localizedDescription)")
            return false
        }
    }
    
    func status() async -> (isAllowed: Bool, isNotDetermined: Bool) {
        let settings = await notificationCenter.notificationSettings()
        switch (settings.authorizationStatus) {
        case .authorized:
            Logger.localNotification.debug("🔔 Permission: Authorized")
            return (isAllowed: true, isNotDetermined: false)
        case .denied:
            Logger.localNotification.debug("🔔 Permission: Denied")
            return (isAllowed: false, isNotDetermined: false)
        case .notDetermined:
            Logger.localNotification.debug("🔔 Permission: Not Determined")
            return (isAllowed: false, isNotDetermined: true)
        default:
            Logger.localNotification.debug("🔔 Permission: Denied / Others")
            return (isAllowed: false, isNotDetermined: false)
        }
    }
    
    func scheduleNow(notification: NotificationItem, amountUsageInPercentage: Int) async {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body(percentage: amountUsageInPercentage)
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: trigger
        )
        do {
            Logger.localNotification.debug("🔔 Notification Scheduling Now with ID: \(notification.id)...")
            try await notificationCenter.add(request)
            Logger.localNotification.debug("🔔 Notification Scheduled Successfully")
        } catch let error {
            Logger.localNotification.debug("🔔 Notification Scheduling Failed: \(error.localizedDescription)")
        }
    }
    
    func removeAll() {
        notificationCenter.removeAllDeliveredNotifications()
        Logger.localNotification.debug("🔔 Notification Removed All Delivered Notifications")
    }
    
    func hasReceived(notification: NotificationItem) async -> Bool {
        let notifications = await notificationCenter.deliveredNotifications()
        Logger.localNotification.debug("🔔 Notification Delivered: \(notifications)")
        let notification = notifications.first(where: { $0.request.identifier == notification.id })
        return notification != nil
    }
    
    // MARK: (3) Receive
    func resetReceivedNotification(notification: NotificationItem) {
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [notification.id])
        Logger.localNotification.debug("🔔 Notification Removed Delivered with ID: \(notification.id)")
    }
}
