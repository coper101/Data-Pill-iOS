//
//  Enums.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import Foundation

public extension CaseIterable where Self: Equatable {

    ///  Gets the index of enum case according to the order declared
    func ordinal() -> Self.AllCases.Index {
        return Self.allCases.firstIndex(of: self)!
    }

}
