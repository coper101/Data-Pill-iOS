//
//  Dimensions.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

// MARK: - Dimensions
struct Dimensions {
    let horizontalPadding: CGFloat = 21
    let cardHeight: CGFloat = 145
    let spaceInBetween: CGFloat = 21
    let screen: CGSize = UIScreen.main.bounds.size
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
