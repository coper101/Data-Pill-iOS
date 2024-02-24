//
//  RemoteAccountOperation.swift
//  Data Pill
//
//  Created by Wind Versi on 2/7/23.
//

import Foundation
import Combine
import CloudKit
import OSLog

extension CloudDatabase {
    
    /// Publishes whether a user has allowed to access his iCloud Database
    func isAvailable() -> AnyPublisher<Bool, Error> {
        Future { promise in
            self.container.accountStatus { accountStatus, error in
                if let error {
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Get Login Status | 😭 FAILED: \(error.localizedDescription)")
                    promise(.failure(RemoteDatabaseError.accountError(.error)))
                    return
                }
                switch accountStatus {
                case .couldNotDetermine:
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Get Login Status | ✅ Could Not Determine")
                    promise(.failure(RemoteDatabaseError.accountError(.couldNotDetermine)))

                case .available:
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Get Login Status | ✅ Available")
                    promise(.success(true))
                    
                case .restricted:
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Get Login Status | ✅ Restricted")
                    promise(.failure(RemoteDatabaseError.accountError(.restricted)))

                case .noAccount:
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Get Login Status | ✅ No Account")
                    promise(.failure(RemoteDatabaseError.accountError(.noAccount)))

                case .temporarilyUnavailable:
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Get Login Status | ✅ Temporarily Unavailable")
                    promise(.failure(RemoteDatabaseError.accountError(.temporarilyUnavailable)))

                @unknown default:
                    Logger.remoteDatabase.debug("- CLOUD DATABASE: ☁️ Get Login Status | ✅ Unknown")
                    promise(.failure(RemoteDatabaseError.accountError(.unknown)))
                }
            }
        } //: Future
        .eraseToAnyPublisher()
    }
}
