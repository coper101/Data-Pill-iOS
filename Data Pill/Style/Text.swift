//
//  Text.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct CustomText: ViewModifier {
    // MARK: - Properties
    var foregroundColor: Color
    var font: String
    var size: Int
    var maxWidth: CGFloat?
    var alignment: Alignment
    var lineLimit: Int?
    var lineSpacing: CGFloat
    var textAlignment: TextAlignment
    
    // MARK: - UI
    func body(content: Content) -> some View {
        content
            .foregroundColor(foregroundColor)
            .font(
                Font.custom(
                    font,
                    size: CGFloat(size)
                )
            )
            .frame(
                maxWidth: maxWidth,
                alignment: alignment
            )
            .lineLimit(lineLimit)
            .lineSpacing(lineSpacing)
            .multilineTextAlignment(textAlignment)
    }
}

extension View {
    
    /// Sets the style of the Text
    ///
    /// - Parameters:
    ///   - foregroundColor: The color of the text
    ///   - font: The custom font e.g. "Arial-Bold"
    ///   - size: The font size
    ///   - maxWidth: The text will fill all the available width of its parent
    ///   - alignment: The alignment of the text relative to its width
    ///   - linelimit: Limit the text per line. Overflowing text in single line will be truncated with ...
    ///   - lineSpacing: The space between lines of text
    ///   - textAlignment: The alignment of multiline text
    ///
    /// - Returns: A Text View with new Style
    func textStyle(
        foregroundColor: Colors = .onSurface,
        font: SFProText = .semibold,
        size: Int,
        maxWidth: CGFloat? = nil,
        alignment: Alignment = .leading,
        lineLimit: Int? = 1,
        lineSpacing: CGFloat = 0,
        textAlignment: TextAlignment = .leading
    ) -> some View {
        self.modifier(
            CustomText(
                foregroundColor: foregroundColor.color,
                font: font.value,
                size: size,
                maxWidth: maxWidth,
                alignment: alignment,
                lineLimit: lineLimit,
                lineSpacing: lineSpacing,
                textAlignment: textAlignment
            )
        )
    }
    
}

extension String {
    
    /// Capitalizes first letter of word
    func firstCap() -> String {
        self.prefix(1).capitalized + dropFirst()
    }
    
}

/**
 Formats the label for Preview
 ```
 "picker", "wheel"     = "Picker / Wheel"
 "picker", "segmented" = "Picker / Segmeted"
 "picker", "inline"    = "Picker / Inline"
 ```
*/
func displayName(_ components: String...) -> String {
    components.reduce("") { acc, component in
        acc + ((acc.isEmpty) ? "" : " / ") + component
    }
}
