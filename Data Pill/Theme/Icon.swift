//
//  Icon.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

enum Icons: String {
    case icon = "iconName"
    var image: Image {
        Image(self.rawValue)
    }
}
