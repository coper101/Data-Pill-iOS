//
//  RemoteErrors.swift
//  Data Pill
//
//  Created by Wind Versi on 2/7/23.
//

import Foundation

enum RemoteDatabaseError: Error, Equatable {
    case saveError(String)
    case fetchError(String)
    case nilProp(String)
    
    var description: String {
        switch self {
        case .saveError(let message):
            return message
        case .fetchError(let message):
            return message
        case .nilProp(let message):
            return message
        }
    }
}
