//
//  Color.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

enum Colors: String {
    // App
    case background = "Background"
    case onBackground = "On Background"
    case onBackgroundLight = "On Background Light"
    
    case surface = "Surface"
    case onSurface = "On Surface"
    case onSurfaceLight = "On Surface Light"
    case onSurfaceLight2 = "On Surface Light 2"
    case onSurfaceDark = "On Surface Dark"
    case onSurfaceDark2 = "On Surface Dark 2"
        
    case tertiary = "Tertiary"
    case onTertiary = "On Tertiary"
    
    case widgetBackground = "Widget Background"
    
    // Day Pill
    case secondaryBlue = "Secondary Blue"
    case secondaryBrown = "Secondary Brown"
    case secondaryGreen = "Secondary Green"
    case secondaryOrange = "Secondary Orange"
    case secondaryPink = "Secondary Pink"
    case secondaryPurple = "Secondary Purple"
    case secondaryRed = "Secondary Red"
    case onSecondary = "On Secondary"
    
    var color: Color {
        Color(self.rawValue)
    }
}

