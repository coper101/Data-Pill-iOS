//
//  Data.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation
import CoreData

@objc(Data)
public class Data: NSManagedObject {
    
    // properties are generated automatically
    // matches the properties from the Entity Table
    // date, totalUsedData, dailyUsedData, hasLastTotal
        
    public var id: String {
        (date ?? Date()).toDayFormat()
    }
    
}

