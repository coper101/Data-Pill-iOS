//
//  Text.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

struct CustomText: ViewModifier {
    var foregroundColor: Color
    var font: String
    var size: Int
    var maxWidth: CGFloat?
    var alignment: Alignment
    var lineLimit: Int?
    var lineSpacing: CGFloat
    
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
    ///
    /// - Returns: A Text View with new Style
    func textStyle(
        foregroundColor: Colors = .primary,
        font: Types = .DMSansBold,
        size: Int,
        maxWidth: CGFloat? = nil,
        alignment: Alignment = .leading,
        lineLimit: Int? = nil,
        lineSpacing: CGFloat = 0
    ) -> some View {
        self.modifier(
            CustomText(
                foregroundColor: foregroundColor.color,
                font: font.value,
                size: size,
                maxWidth: maxWidth,
                alignment: alignment,
                lineLimit: lineLimit,
                lineSpacing: lineSpacing
            )
        )
    }
    
}
