//
//  Mock_Success_Data_Usage_Remote_Repository.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 25/6/23.
//

import Foundation
import Combine
import CloudKit

final class MockSuccessDataUsageRemoteRepository: ObservableObject, DataUsageRemoteRepositoryProtocol {
    
    @Published var uploadOldDataCount = 0
    var uploadOldDataCountPublisher: Published<Int>.Publisher { $uploadOldDataCount }

    @Published var uploadOldDataTotalCount = 0
    var uploadOldDataTotalCountPublisher: Published<Int>.Publisher { $uploadOldDataTotalCount }

    @Published var downloadOldDataTotalCount = 0
    var downloadOldDataTotalCountPublisher: Published<Int>.Publisher { $downloadOldDataTotalCount }
    
    
    // MARK: - User
    func isDatabaseAccessible() -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Plan
    func isPlanAdded() -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getPlan() -> AnyPublisher<RemotePlan?, Error> {
        Just(TestData.createEmptyRemotePlan())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addPlan(_ plan: RemotePlan) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updatePlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Data
    func isDataAdded(on date: Date) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getData(on date: Date) -> AnyPublisher<RemoteData?, Error> {
        Just(TestData.createEmptyRemoteData())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addData(_ bulkData: [RemoteData]) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addData(_ data: RemoteData) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateData(_ data: [RemoteData]) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateData(date: Date, dailyUsedData: Double) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Synchronization
    func syncPlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func syncTodaysData(_ todaysData: Data_Pill.Data, isSyncedToRemote: Bool) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func syncOldLocalData(_ localData: [Data_Pill.Data], lastSyncedDate: Date?) -> AnyPublisher<(Bool, Bool, [RemoteData]), Error>   {
        Just((true, true, []))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func syncOldRemoteData(_ localData: [Data_Pill.Data], excluding date: Date) -> AnyPublisher<[RemoteData], Error> {
        Just([
            TestData.createEmptyRemoteData(),
            TestData.createEmptyRemoteData()
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    // MARK: - Subscription
    func subscribeToRemotePlanChanges() -> AnyPublisher<Bool, Never> {
        Just(true)
            .eraseToAnyPublisher()
    }
    
    func subscribeToRemoteTodaysDataChanges() -> AnyPublisher<Bool, Never> {
        Just(true)
            .eraseToAnyPublisher()
    }
}
