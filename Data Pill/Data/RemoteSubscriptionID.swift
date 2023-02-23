//
//  RemoteSubscriptionID.swift
//  Data Pill
//
//  Created by Wind Versi on 23/2/23.
//

import Foundation

enum RemoteSubscription: String {
    case plan = "On_Change_Plan_Subscription"
    case todaysData = "On_Change_Todays_Data_Subscription"
    
    var id: String {
        self.rawValue
    }
}

extension Notification.Name {
    static let plan = Notification.Name(rawValue: RemoteSubscription.plan.id)
    static let todaysData = Notification.Name(rawValue: RemoteSubscription.todaysData.id)
}
