//
//  Type.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import Foundation

enum SFProText: String {
    case bold = "SFProText-Bold"
    case medium = "SFProText-Medium"
    case semibold = "SFProText-Semibold"
    case heavy = "SFProText-Heavy"
    var value: String {
        self.rawValue
    }
}
