//
//  Color.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

enum Colors: String {
    // App
    case background = "White"
    case onBackground = "Black"
    case onBackgroundLight = "Gray300"
    case surface = "Gray50"
    case onSurface = "Gray"
    case onSurfaceDark = "Gray10"
    case onSurfaceDark2 = "Gray20"
    case onSurfaceLight = "Gray200"
    case onSurfaceLight2 = "Gray100"
    // Day Pill
    case secondaryBlue = "Blue"
    case secondaryBrown = "Brown"
    case secondaryGreen = "Green"
    case secondaryOrange = "Orange"
    case secondaryPink = "Pink"
    case secondaryPurple = "Purple"
    case secondaryRed = "Red"
    static let onSecondary = Self.background
    static let tertiary = Self.onSurface
    static let onTertiary = Self.background
    var color: Color {
        Color(self.rawValue)
    }
}

