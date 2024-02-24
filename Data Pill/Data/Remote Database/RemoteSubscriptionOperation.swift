//
//  RemoteSubscriptionOperation.swift
//  Data Pill
//
//  Created by Wind Versi on 2/7/23.
//

import Foundation
import Combine
import CloudKit
import OSLog

extension CloudDatabase {
    
    func createOnUpdateRecordSubscription(of recordType: RecordType, id subscriptionID: String) -> AnyPublisher<Bool, Never> {
        Future { promise in
            let subscription = CKQuerySubscription(
                recordType: recordType.type, predicate: .init(value: true),
                subscriptionID: subscriptionID,
                options: .firesOnRecordUpdate
            )
            let notification = CKSubscription.NotificationInfo()
            notification.shouldSendContentAvailable = true // silent notification
            subscription.notificationInfo = notification
            
            self.database.save(subscription) { _, error in
                if let error {
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Create Subscription | 😭 ERROR: \(error.localizedDescription)")
                    promise(.success(false))
                    return
                }
                Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Create Subscription | ✅ Created")
                promise(.success(true))
            }
        } //: Future
        .eraseToAnyPublisher()
    }
    
    func fetchAllSubscriptions() -> AnyPublisher<[String], Never> {
        Future { promise in
            self.database.fetchAllSubscriptions { subscriptions, error in
                if let error {
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch All Subscriptions | 😭 ERROR: \(error.localizedDescription)")
                    promise(.success([]))
                    return
                }
                guard let subscriptions else {
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch All Subscriptions | 😭 ERROR: Subscriptions is Nil")
                    return
                }
                Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Fetch All Subscriptions | ✅ Subscription IDs: \(subscriptions.map(\.subscriptionID))")
                promise(.success(subscriptions.map(\.subscriptionID)))
            } //: fetchAll
        }
        .eraseToAnyPublisher()
    }
}
