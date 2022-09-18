//
//  Color.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

enum Colors: String {
    case background = "Black"
    case primary = "White"
    var color: Color {
        Color(self.rawValue)
    }
}
