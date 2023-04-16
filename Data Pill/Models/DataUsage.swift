//
//  DataUsage.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation
import CoreData
import CloudKit

public extension NSManagedObject {
    convenience init(using usedContext: NSManagedObjectContext) {
        let name = String(describing: type(of: self))
        let entity = NSEntityDescription.entity(forEntityName: name, in: usedContext)!
        self.init(entity: entity, insertInto: usedContext)
    }
}

// MARK: Local
public class Data: NSManagedObject {
    
    // properties are generated automatically
    // matches the properties from the Entity Table
    // date, totalUsedData, dailyUsedData, hasLastTotal, isSyncedToRemote
        
    public var id: String {
        (date ?? Date()).toDayFormat()
    }
    
    public override var description: String {
        """
              Date: \(date ?? Date())
              Total Used Data: \(totalUsedData) MB
              Daily Used Data: \(dailyUsedData) MB
              Has Last Total: \(hasLastTotal)
              Is Synced To Remote: \(isSyncedToRemote)
            """
    }
    
    convenience init(
        date: Date = .init(),
        totalUsedData: Double = 0,
        dailyUsedData: Double = 0,
        hasLastTotal: Bool = false,
        isSyncedToRemote: Bool = false,
        insertInto context: NSManagedObjectContext? = nil
    ) {
        self.init(entity: Data.entity(), insertInto: context)
        self.date = date
        self.totalUsedData = totalUsedData
        self.dailyUsedData = dailyUsedData
        self.hasLastTotal = hasLastTotal
        self.isSyncedToRemote = isSyncedToRemote
    }

}

func createFakeData(
    date: Date = .init(),
    totalUsedData: Double = 0,
    dailyUsedData: Double = 0,
    hasLastTotal: Bool = false,
    isSyncedToRemote: Bool = false
) -> Data {
    .init(
        date: date,
        totalUsedData: totalUsedData,
        dailyUsedData: dailyUsedData,
        hasLastTotal: hasLastTotal,
        isSyncedToRemote: isSyncedToRemote
    )
}

// MARK: Remote
struct RemoteData {
    var id: CKRecord.ID? = nil
    let date: Date
    let dailyUsedData: Double
}

extension RemoteData {
    func toDictionary() -> [String : Any] {
        [
            "date": date,
            "dailyUsedData": dailyUsedData
        ]
    }
    static func toRemoteData(_ record: CKRecord) -> RemoteData? {
        guard
            let date = record.value(forKey: "date") as? Date,
            let dailyUsedData = record.value(forKey: "dailyUsedData") as? Double
        else {
            return nil
        }
        let startDate = Calendar.current.startOfDay(for: date)
        return .init(date: startDate, dailyUsedData: dailyUsedData)
    }
}

extension RemoteData: Equatable {
    static func ==(lhs: RemoteData, rhs: RemoteData) -> Bool {
        lhs.id == rhs.id &&
        lhs.date == rhs.date &&
        lhs.dailyUsedData == rhs.dailyUsedData
    }
}
