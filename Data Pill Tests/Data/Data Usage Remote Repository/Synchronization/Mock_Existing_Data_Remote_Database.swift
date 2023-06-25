//
//  Mock_Existing_Data_Remote_Database.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 25/6/23.
//

@testable import Data_Pill
import Foundation
import Combine
import CloudKit

final class MockTwoExistingDataRemoteDatabase: RemoteDatabase {
    
    func fetchAll(of recordType: RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
        guard recursively else {
            return Just([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        let todaysDate = Calendar.current.startOfDay(for: .init())
        let records: [CKRecord] = [
            TestData.createDataRecord(
                date:  Calendar.current.date(byAdding: .day, value: -1, to: todaysDate)!,
                dailyUsedData: 100
            ),
            TestData.createDataRecord(
                date: Calendar.current.date(byAdding: .day, value: -2, to: todaysDate)!,
                dailyUsedData: 200
            )
        ]
        return Just(records)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

//final class MockFailToFetchAllDataRemoteDatabase: RemoteDatabase {
//
//    func fetchAll(of recordType: RecordType, recursively: Bool) -> AnyPublisher<[CKRecord], Error> {
//        Fail(error: RemoteDatabaseError.fetchError("Fetch Error"))
//            .eraseToAnyPublisher()
//    }
//}
