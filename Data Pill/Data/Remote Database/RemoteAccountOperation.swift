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
    
    func checkLoginStatus() -> AnyPublisher<Bool, Never> {
        Future { promise in
            self.container.accountStatus { accountStatus, error in
                guard accountStatus == .available else {
                    Logger.remoteDatabase.debug("checkLoginStatus - is not logged in or disabled iCloud")
                    promise(.success(false))
                    return
                }
                Logger.remoteDatabase.debug("checkLoginStatus - is logged in")
                promise(.success(true))
            }
        } //: Future
        .eraseToAnyPublisher()
    }
}
