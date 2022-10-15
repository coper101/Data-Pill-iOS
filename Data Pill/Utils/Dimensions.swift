//
//  Dimensions.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

// MARK: - Dimensions
struct Dimensions {
    let topBarHeight: CGFloat = 76
    let bottomBarHeight: CGFloat = 62
    let horizontalPadding: CGFloat = 21
    let screen: CGSize = UIScreen.main.bounds.size
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

// MARK: - Insets
typealias EdgeInset = (
    top: CGFloat,
    bottom: CGFloat,
    leading: CGFloat,
    trailing: CGFloat
)

struct EdgeInsetsKey: EnvironmentKey {
    static let defaultValue: EdgeInset = insets
    static var insets: EdgeInset {
        let insets = UIApplication.shared.windows.first?.safeAreaInsets
        return (
            insets?.top ?? 0,
            insets?.bottom ?? 0,
            insets?.left ?? 0,
            insets?.right ?? 0
        )
    }
}

extension EnvironmentValues {
    var edgeInsets: EdgeInset {
        get { self[EdgeInsetsKey.self] }
        set { }
    }
}
