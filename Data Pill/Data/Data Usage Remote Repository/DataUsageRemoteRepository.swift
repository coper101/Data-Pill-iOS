//
//  DataUsageRemoteRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 4/2/23.
//

import Foundation
import Combine
import CloudKit
import OSLog

// MARK: - Protocol
protocol DataUsageRemoteRepositoryProtocol {
    
    // MARK: - User
    /// - Read
    func isDatabaseAccessible() -> AnyPublisher<Bool, Error>
    
        
    // MARK: - Data
    /// - Read
    func isDataAdded(on date: Date) -> AnyPublisher<Bool, Error>
    
    func getData(on date: Date) -> AnyPublisher<RemoteData?, Error>
    
    /// - Add
    func addData(_ data: RemoteData) -> AnyPublisher<Bool, Error>
    
    func addData(_ bulkData: [RemoteData]) -> AnyPublisher<Bool, Error>
    
    /// - Update
    func updateData(date: Date, dailyUsedData: Double) -> AnyPublisher<Bool, Error>
    
    func updateData(_ data: [RemoteData]) -> AnyPublisher<Bool, Error>
    
    
    // MARK: - Plan
    /// - Read
    func isPlanAdded() -> AnyPublisher<Bool, Error>
    
    func getPlan() -> AnyPublisher<RemotePlan?, Error>
    
    /// - Add
    func addPlan(_ plan: RemotePlan) ->  AnyPublisher<Bool, Error>
    
    /// - Update
    func updatePlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) -> AnyPublisher<Bool, Error>
    
    
    // MARK: - Synchronization
    /// - Plan
    func syncPlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) -> AnyPublisher<Bool, Error>
    
    /// - Today's Data
    func syncTodaysData(_ todaysData: Data, isSyncedToRemote: Bool) -> AnyPublisher<Bool, Error>
   
    /// - Old Data
    func syncOldLocalData(_ localData: [Data], lastSyncedDate: Date?) -> AnyPublisher<(Bool, Bool, [RemoteData]), Error>
   
    func syncOldRemoteData(_ localData: [Data], excluding date: Date) -> AnyPublisher<[RemoteData], Error>
    
    /// - Subscription
    func subscribeToRemotePlanChanges() -> AnyPublisher<Bool, Never>
    
    func subscribeToRemoteTodaysDataChanges() -> AnyPublisher<Bool, Never>
}



// MARK: - App Implementation
class DataUsageRemoteRepository: ObservableObject, DataUsageRemoteRepositoryProtocol {
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    
    // MARK: - Dependencies
    let remoteDatabase: RemoteDatabase
    
    
    // MARK: - Initializer
    init(remoteDatabase: RemoteDatabase) {
        self.remoteDatabase = remoteDatabase
    }
}
