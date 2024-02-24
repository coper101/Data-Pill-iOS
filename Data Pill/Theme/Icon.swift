//
//  Icon.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

enum Icons: String {
    case bellIcon = "Bell"
    case bugIcon = "Bug"
    case closeIcon = "X Mark Icon"
    case deleteIcon = "Delete"
    case dataPacket = "Data Packet"
    case moonIcon = "Moon"
    case fileIcon = "File"
    case minusIcon = "Minus"
    case navigateIcon = "Right Arrow Icon"
    case navigateThickIcon = "Right Arrow Thick"
    case pillIcon = "Pill"
    case plusIcon = "Plus"
    case settingsIcon = "Settings"
    case starIcon = "Star"
    case warningIcon = "Warning Icon"
    var image: Image {
        Image(self.rawValue)
    }
}
