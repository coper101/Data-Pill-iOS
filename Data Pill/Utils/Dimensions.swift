//
//  Dimensions.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct Dimensions {
    static let TopBarHeight: CGFloat = 76
    static let BottomBarHeight: CGFloat = 62
    static let HorizontalPadding: CGFloat = 21
    static let Screen: CGSize = UIScreen.main.bounds.size
}

struct EdgeInsets {
    
    func getKeyWindows() -> UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
    var insets: (
        top: CGFloat,
        bottom: CGFloat,
        leading: CGFloat,
        trailing: CGFloat
    ) {
        let insets = getKeyWindows()?.safeAreaInsets ?? .zero
        return (
            insets.top,
            insets.bottom,
            insets.left,
            insets.right
        )
    }
}
