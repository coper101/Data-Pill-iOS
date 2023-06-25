//
//  DataPlan.swift
//  Data Pill
//
//  Created by Wind Versi on 5/12/22.
//

import Foundation
import CoreData
import CloudKit

// MARK: - Local
public class Plan: NSManagedObject {
    
    /// properties are generated automatically
    /// matches the properties from the Entity Table
    /// `startDate`, `endDate`, `dataAmount`, `dailyLimit`, `planLimit`
        
    public override var description: String {
        """
              Start Date: \(startDate ?? Date())
              End Date: \(endDate ?? Date())
              Data Amount: \(dataAmount)
              Daily Limit: \(dailyLimit)
              Plan Limit: \(planLimit)
            """
    }
    
    convenience init(
        startDate: Date = .init(),
        endDate: Date = .init(),
        dataAmount: Double = 0,
        dailyLimit: Double = 0,
        planLimit: Double = 0,
        insertInto context: NSManagedObjectContext? = nil
    ) {
        self.init(entity: Plan.entity(), insertInto: context)
        self.startDate = startDate
        self.endDate = endDate
        self.dataAmount = dataAmount
        self.dailyLimit = dailyLimit
        self.planLimit = planLimit
    }

}

func createFakePlan(
    startDate: Date = .init(),
    endDate: Date = .init(),
    dataAmount: Double = 0,
    dailyLimit: Double = 0,
    planLimit: Double = 0
) -> Plan {
    .init(
        startDate: startDate,
        endDate: endDate,
        dataAmount: dataAmount,
        dailyLimit: dailyLimit,
        planLimit: planLimit
    )
}



// MARK: - Remote
struct RemotePlan {
    var id: CKRecord.ID? = nil
    let startDate: Date
    let endDate: Date
    let dataAmount: Double
    let dailyLimit: Double
    let planLimit: Double
}

extension RemotePlan {
    func toDictionary() -> [String : Any] {
        [
            "startDate": startDate,
            "endDate": endDate,
            "dataAmount": dataAmount,
            "dailyLimit": dailyLimit,
            "planLimit": planLimit
        ]
    }
    static func toRemotePlan(_ record: CKRecord) -> RemotePlan? {
        guard
            let startDate = record.value(forKey: "startDate") as? Date,
            let endDate = record.value(forKey: "endDate") as? Date,
            let dataAmount = record.value(forKey: "dataAmount") as? Double,
            let dailyLimit = record.value(forKey: "dailyLimit") as? Double,
            let planLimit = record.value(forKey: "planLimit") as? Double
        else {
            return nil
        }
        return .init(
            startDate: startDate,
            endDate: endDate,
            dataAmount: dataAmount,
            dailyLimit: dailyLimit,
            planLimit: planLimit
        )
    }
}

extension RemotePlan: Equatable {
    static func ==(lhs: RemotePlan, rhs: RemotePlan) -> Bool {
        lhs.id == rhs.id &&
        lhs.startDate == rhs.startDate &&
        lhs.endDate == rhs.endDate &&
        lhs.dataAmount == rhs.dataAmount &&
        lhs.dailyLimit == rhs.dailyLimit &&
        lhs.planLimit == rhs.planLimit
    }
}
