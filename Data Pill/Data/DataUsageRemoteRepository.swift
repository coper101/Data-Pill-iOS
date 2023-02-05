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
    ) -> AnyPublisher<Bool, Never>
    
    /// [B] Data
    func addData(_ data: RemoteData) -> Void
    func updateData(data: Date) -> Void
    
    /// [C] User
    func isLoggedInUser() -> AnyPublisher<Bool, Never>
}


// MARK: App Implementation
class DataUsageRemoteRepository: DataUsageRemoteRepositoryProtocol {
    
    var cancellables: Set<AnyCancellable> = .init()
    
    let remoteDatabase: RemoteDatabase
    
    init(remoteDatabase: RemoteDatabase) {
        self.remoteDatabase = remoteDatabase
    }
    
    /// [A]
    func isPlanAdded() -> AnyPublisher<Bool, Never> {
        remoteDatabase.fetchAll(of: .plan)
            .map { $0.count > 0 }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
    
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
    
    func updatePlan(
        startDate: Date?,
        endDate: Date?,
        dataAmount: Double?,
        dailyLimit: Double?,
        planLimit: Double?
    ) -> AnyPublisher<Bool, Never> {
        remoteDatabase.fetchAll(of: .plan)
            .replaceError(with: [])
            .eraseToAnyPublisher()
            .map(\.first)
            .flatMap {
                guard let planRecord = $0 else {
                    return Just(false).eraseToAnyPublisher()
                }
                
                if let startDate {
                    planRecord.setValue(startDate, forKey: "startDate")
                }

                if let endDate {
                    planRecord.setValue(endDate, forKey: "endDate")
                }

                if let dataAmount {
                    planRecord.setValue(dataAmount, forKey: "dataAmount")
                }

                if let dailyLimit {
                    planRecord.setValue(dailyLimit, forKey: "dailyLimit")
                }

                if let planLimit {
                    planRecord.setValue(planLimit, forKey: "planLimit")
                }
                
                return self.remoteDatabase.save(record: planRecord)
                    .replaceError(with: false)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// [B]
    // add for today or previous data not found in remote database
    func addData(_ data: RemoteData) {
        // let record = CKRecord(recordType: RecordType.data.rawValue)

    }
    
    // update for today
    func updateData(data: Date) {
        
    }
    
    /// [C]
    func isLoggedInUser() -> AnyPublisher<Bool, Never> {
        remoteDatabase.checkLoginStatus()
    }
}
