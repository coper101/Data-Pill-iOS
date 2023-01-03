//
//  Dimensions.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

// MARK: - Dimensions
struct Dimensions {
    var isSmallDevice: Bool {
        screen.width <= 320
    }
    
    /// Padding
    let horizontalPadding: CGFloat = 21
    let spaceInBetween: CGFloat = 21
    
    /// Card
    let planCardHeight: CGFloat = 150
    let planLimitCardsHeight: CGFloat = 145
    let limitCardWidth: CGFloat = 286
    var planCardWidth: CGFloat {
        isSmallDevice ? 280 : 331
    }
    let maxPillHeight: CGFloat = 390
    
    /// Calendar
    var calendarWidth: CGFloat {
        isSmallDevice ? 295 : 320
    }
    
    /// Pill
    var pillWidth: CGFloat {
        isSmallDevice ? 134 : 171
    }
    var pillHeight: CGFloat {
        isSmallDevice ? 340 : 390
    }
    
    /// Button
    let buttonHeight: CGFloat = 53
    let buttonHeightTall: CGFloat = 62
    
    let screen: CGSize = UIScreen.main.bounds.size
    
    @available(iOSApplicationExtension, unavailable)
    let insets: EdgeInset = theInsets
    
    static var theInsets: EdgeInset {
        let insets = UIApplication.shared.windows.first?.safeAreaInsets
        return (
            insets?.top ?? 0,
            insets?.bottom ?? 0,
            insets?.left ?? 0,
            insets?.right ?? 0
        )
    }
}

struct DimensionsKey: EnvironmentKey {
    static var defaultValue: Dimensions = .init()
}

extension EnvironmentValues {
    var dimensions: Dimensions {
        get { self[DimensionsKey.self] }
        set { }
    }
}

typealias EdgeInset = (
    top: CGFloat,
    bottom: CGFloat,
    leading: CGFloat,
    trailing: CGFloat
)
