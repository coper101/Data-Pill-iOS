//
//  Mock_Fail_Data_Usage_Remote_Repository.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 25/6/23.
//

@testable import Data_Pill
import Foundation
import Combine
import CloudKit

final class MockFailDataUsageRemoteRepository: ObservableObject, DataUsageRemoteRepositoryProtocol {
    
    func isPlanAdded() -> AnyPublisher<Bool, Error> {
        Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getPlan() -> AnyPublisher<RemotePlan?, Error> {
        Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addPlan(_ plan: RemotePlan) -> AnyPublisher<Bool, Error> {
        Just(false)
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
        Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func isDataAdded(on date: Date) -> AnyPublisher<Bool, Error> {
        Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getData(on date: Date) -> AnyPublisher<RemoteData?, Error> {
        Just(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addData(_ bulkData: [RemoteData]) -> AnyPublisher<Bool, Error> {
        Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func addData(_ data: RemoteData) -> AnyPublisher<Bool, Error> {
        Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateData(_ data: [RemoteData]) -> AnyPublisher<Bool, Error> {
        Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func updateData(date: Date, dailyUsedData: Double) -> AnyPublisher<Bool, Error> {
        Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func isLoggedInUser() -> AnyPublisher<Bool, Never> {
        Just(false)
            .eraseToAnyPublisher()
    }
    
    func syncPlan(
        startDate: Date,
        endDate: Date,
        dataAmount: Double,
        dailyLimit: Double,
        planLimit: Double
    ) -> AnyPublisher<Bool, Error> {
        Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func syncTodaysData(_ todaysData: Data_Pill.Data, isSyncedToRemote: Bool) -> AnyPublisher<Bool, Error> {
        Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func syncOldLocalData(_ localData: [Data_Pill.Data], lastSyncedDate: Date?) -> AnyPublisher<(Bool, Bool, [RemoteData]), Error>  {
        Just((false, false, []))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func syncOldRemoteData(_ localData: [Data_Pill.Data], excluding date: Date) -> AnyPublisher<[RemoteData], Error> {
        Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func subscribeToRemotePlanChanges() -> AnyPublisher<Bool, Never> {
        Just(false)
            .eraseToAnyPublisher()
    }
    
    func subscribeToRemoteTodaysDataChanges() -> AnyPublisher<Bool, Never> {
        Just(false)
            .eraseToAnyPublisher()
    }
}
