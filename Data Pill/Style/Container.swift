//
//  Container.swift
//  Data Pill
//
//  Created by Wind Versi on 23/1/24.
//

import SwiftUI

struct SectionModifier: ViewModifier {
    // MARK: Props
    var title: String?
    var atTop: Bool
    var alignment: HorizontalAlignment
    
    // MARK: UI
    func body(content: Content) -> some View {
        VStack(alignment: alignment, spacing: 12) {
            
            // MARK: HEADER (TOP)
            if atTop, let title {
                
                Text(title.uppercased())
                    .textStyle(
                        foregroundColor: .onSurfaceLight,
                        size: 14
                    )
                
            } //: if
            
            // MARK: CONTENT
            content
            
            // MARK: HEADER (BOTTOM)
            if !atTop, let title {
                
                Text(title.uppercased())
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
        title: String?,
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
    
    func rowSection(title: String?) -> some View {
        self
            .background(Colors.surface.color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .section(title: title)
    }
    
    func textFieldStyle(title: String, lineLimit: Int = 1) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            
            Text(title)
                .textStyle(
                    foregroundColor: .onSurfaceLight,
                    size: 12
                )
            
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
            
        } //: VStack
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .rowSection(title: nil)
    }
}
