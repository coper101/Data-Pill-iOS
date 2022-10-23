//
//  DataUsage.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation
import CoreData

public class Data: NSManagedObject {
    
    // properties are generated automatically
    // matches the properties from the Entity Table
    // date, totalUsedData, dailyUsedData, hasLastTotal
        
    public var id: String {
        (date ?? Date()).toDayFormat()
    }
    
    public override var description: String {
        """
              Date: \(date ?? Date())
              Total Used Data: \(totalUsedData) MB
              Daily Used Data: \(dailyUsedData) MB
              Has Last Total: \(hasLastTotal)
            """
    }
    
    convenience init(
        date: Date = .init(),
        totalUsedData: Double = 0,
        dailyUsedData: Double = 0,
        hasLastTotal: Bool = false,
        insertInto context: NSManagedObjectContext? = nil
    ) {
        self.init(entity: Data.entity(), insertInto: context)
        self.date = date
        self.totalUsedData = totalUsedData
        self.dailyUsedData = dailyUsedData
        self.hasLastTotal = hasLastTotal
    }

}

func createFakeData(
    date: Date = .init(),
    totalUsedData: Double = 0,
    dailyUsedData: Double = 0,
    hasLastTotal: Bool = false
) -> Data {
    Data(
        date: date,
        totalUsedData: totalUsedData,
        dailyUsedData: dailyUsedData,
        hasLastTotal: hasLastTotal
    )
}
