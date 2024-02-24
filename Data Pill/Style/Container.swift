//
//  Container.swift
//  Data Pill
//
//  Created by Wind Versi on 23/1/24.
//

import SwiftUI

struct SectionModifier: ViewModifier {
    // MARK: Props
    var title: LocalizedStringKey?
    var atTop: Bool
    var alignment: HorizontalAlignment
    
    // MARK: UI
    func body(content: Content) -> some View {
        VStack(alignment: alignment, spacing: 12) {
            
            // MARK: HEADER (TOP)
            if atTop, let title {
                
                Text(title)
                    .textStyle(
                        foregroundColor: .onSurfaceLight,
                        size: 14
                    )
                
            } //: if
            
            // MARK: CONTENT
            content
            
            // MARK: HEADER (BOTTOM)
            if !atTop, let title {
                
                Text(title)
                    .textStyle(
                        foregroundColor: .onSurfaceLight,
                        size: 14
                    )
                
            } //: if
            
        } //: VStack
    }
}




extension View {
    
    func section(
        title: LocalizedStringKey?,
        atTop: Bool = true,
        alignment: HorizontalAlignment = .leading
    ) -> some View {
        self.modifier(
            SectionModifier(
                title: title,
                atTop: atTop,
                alignment: alignment
            )
        )
    }
    
    func rowSection(title: LocalizedStringKey?, background: Colors = .surface) -> some View {
        self
            .background(background.color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .section(title: title)
    }
    
    func cardStyle(
        title: LocalizedStringKey,
        titleColor: Colors = .onSurfaceLight,
        lineLimit: Int = 1,
        contentPadding: Bool = true,
        background: Colors = .surface
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            
            Text(title)
                .textStyle(
                    foregroundColor: titleColor,
                    size: 12
                )
                .padding(.horizontal, 14)
            
            self
                .frame(
                    height: (lineLimit > 1) ? 100 : nil,
                    alignment: .topLeading
                )
                .textStyle(
                    foregroundColor: .onSurface,
                    size: 16,
                    lineLimit: lineLimit
                )
                .padding(.horizontal, contentPadding ? 14 : 0)
            
        } //: VStack
        .padding(.vertical, 12)
        .rowSection(title: nil, background: background)
    }
}
