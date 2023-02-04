//
//  DataUsageRemoteRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 4/2/23.
//

import Foundation
import Combine
import CloudKit

// MARK: Protocol
protocol DataUsageRemoteRepositoryProtocol {
    
    /// [A] Plan
    func isPlanAdded() -> AnyPublisher<Bool, Never>
    func addPlan(_ plan: RemotePlan) ->  AnyPublisher<Bool, Never>
    func updatePlan(
        startDate: Date?,
        endDate: Date?,
        dataAmount: Double?,
        dailyLimit: Double?,
        planLimit: Double?
    ) -> Void
    
    /// [B] Data
    func addData(_ data: RemoteData) -> Void
    func updateData(data: Date) -> Void
}


// MARK: App Implementation
class DataUsageRemoteRepository: DataUsageRemoteRepositoryProtocol {
    
    var cancellables: Set<AnyCancellable> = .init()
    
    let remoteDatabase: RemoteDatabase
    
    init(remoteDatabase: RemoteDatabase) {
        self.remoteDatabase = remoteDatabase
    }
    
    func isPlanAdded() -> AnyPublisher<Bool, Never> {
        remoteDatabase.checkLoginStatus()
            .flatMap { isLoggedIn in
                if isLoggedIn {
                    return self.remoteDatabase.fetchAll(of: .plan)
                        .map { $0.count > 0 }
                        .replaceError(with: false)
                        .eraseToAnyPublisher()
                }
                return Just(false).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // add for new users
    func addPlan(_ plan: RemotePlan) -> AnyPublisher<Bool, Never> {
        
        let record = CKRecord(recordType: RecordType.plan.rawValue)
        record.setValuesForKeys(plan.toDictionary())
                
        return remoteDatabase.save(record: record)
            .flatMap { isSaved in
                Just(isSaved)
                    .eraseToAnyPublisher()
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
    // update for existing users
    func updatePlan(
        startDate: Date?,
        endDate: Date?,
        dataAmount: Double?,
        dailyLimit: Double?,
        planLimit: Double?
    ) {
        
    }
    
    // add for today or previous data not found in remote database
    func addData(_ data: RemoteData) {
        let record = CKRecord(recordType: RecordType.data.rawValue)

    }
    
    // update for today
    func updateData(data: Date) {
        
    }
}
