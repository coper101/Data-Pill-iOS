//
//  RemoteUserOperation.swift
//  Data Pill
//
//  Created by Wind Versi on 2/7/23.
//

import Foundation
import Combine

extension DataUsageRemoteRepository {
    
    /// Publishes whether the ``RemoteDatabase`` is accessible or not for performing operations such
    /// as ``getData()``, ``getData()``, ``updateData()``
    func isLoggedInUser() -> AnyPublisher<Bool, Never> {
        remoteDatabase.checkLoginStatus()
    }
}
