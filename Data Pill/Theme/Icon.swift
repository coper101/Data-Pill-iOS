//
//  Icon.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

enum Icons: String {
    case navigateIcon = "Right Arrow Icon"
    case closeIcon = "X Mark Icon"
    var image: Image {
        Image(self.rawValue)
    }
}
