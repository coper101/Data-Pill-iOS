//
//  Mock_Data_Usage_Remote_Sync.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 21/6/23.
//

@testable import Data_Pill
import Foundation
import Combine
import CloudKit

final class MockRemoteDatabase: RemoteDatabase {
    
    func createOnUpdateRecordSubscription(
        of recordType: Data_Pill.RecordType,
        id subscriptionID: String
    ) -> AnyPublisher<Bool, Never> {
        Just(true)
            .eraseToAnyPublisher()
    }
    
    func fetchAllSubscriptions() -> AnyPublisher<[String], Never> {
        Just([])
            .eraseToAnyPublisher()
    }
    
    func checkLoginStatus() -> AnyPublisher<Bool, Never> {
        Just(true)
            .eraseToAnyPublisher()
    }
    
    func fetch(with predicate: NSPredicate, of recordType: Data_Pill.RecordType) -> AnyPublisher<[CKRecord], Error> {
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let yesterdaysDate = TestData.createDate(offset: -1, from: todaysDate)
        if
            recordType == .data,
            predicate.description == "ANY {\(yesterdaysDate)} == date"
        {
            let remoteData = RemoteData(date: yesterdaysDate, dailyUsedData: 100)
            let records = [remoteData].map { data in
                let record = CKRecord(recordType: RecordType.data.rawValue)
                record.setValuesForKeys(data.toDictionary())
                return record
            }
            return Just(records)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func fetchAll(of recordType: Data_Pill.RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
        Just([
            TestData.createDataRecord(
                date: TestData.createDate(offset: -1, from: .init()),
                dailyUsedData: 100
            )
        ])
        .setFailureType(to: Error.self)
        .eraseToAnyPublisher()
    }
    
    func save(record: CKRecord) -> AnyPublisher<Bool, Error> {
        Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func save(records: [CKRecord]) -> AnyPublisher<Bool, Error> {
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let yesterdaysDate = TestData.createDate(offset: -1, from: todaysDate)
        if
            let firstRecord = records.first,
            let date = firstRecord.value(forKey: "date") as? Date,
            date.description == yesterdaysDate.description,
            let dailyUsedData = firstRecord.value(forKey: "dailyUsedData") as? Double,
            dailyUsedData == 200
        {
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return Just(records.count == 2)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
