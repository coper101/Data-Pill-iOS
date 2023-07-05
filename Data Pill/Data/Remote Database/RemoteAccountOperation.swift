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
                    Logger.remoteDatabase.debug("checkLoginStatus - error: \(error.localizedDescription)")
                    promise(.failure(RemoteDatabaseError.accountError(.error)))
                    return
                }
                switch accountStatus {
                case .couldNotDetermine:
                    Logger.remoteDatabase.debug("checkLoginStatus - status: could not determine")
                    promise(.failure(RemoteDatabaseError.accountError(.couldNotDetermine)))

                case .available:
                    Logger.remoteDatabase.debug("checkLoginStatus - status: is available")
                    promise(.success(true))
                    
                case .restricted:
                    Logger.remoteDatabase.debug("checkLoginStatus - status: restricted")
                    promise(.failure(RemoteDatabaseError.accountError(.restricted)))

                case .noAccount:
                    Logger.remoteDatabase.debug("checkLoginStatus - status: no account")
                    promise(.failure(RemoteDatabaseError.accountError(.noAccount)))

                case .temporarilyUnavailable:
                    Logger.remoteDatabase.debug("checkLoginStatus - status: temporarily unavailable")
                    promise(.failure(RemoteDatabaseError.accountError(.temporarilyUnavailable)))

                @unknown default:
                    Logger.remoteDatabase.debug("checkLoginStatus - status: unknown")
                    promise(.failure(RemoteDatabaseError.accountError(.unknown)))
                }
            }
        } //: Future
        .eraseToAnyPublisher()
    }
}
