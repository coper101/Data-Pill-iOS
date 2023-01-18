//
//  DateInputView.swift
//  Data Pill
//
//  Created by Wind Versi on 26/9/22.
//

import SwiftUI

struct DateInputView: View {
    // MARK: - Props
    @Environment(\.locale) var locale: Locale
    @Environment(\.dimensions) var dimensions: Dimensions
    
    var date: Date
    var title: LocalizedStringKey
    var action: () -> Void
    
    var displayedDate: String {
        let isLongYear = !dimensions.isSmallDevice
        return date.toDayMonthYearFormat(isLongYear: isLongYear).uppercased()
    }
    
    // MARK: - UI
    var body: some View {
        VStack(spacing: 10) {
            
            // Row 1: TITLE
            Text(
                title,
                comment: "Title of the date range input"
            )
                .textStyle(
                    foregroundColor: .onSurfaceLight,
                    font: .semibold,
                    size: 17,
                    maxWidth: .infinity
                )
                .accessibilityLabel(AccessibilityLabels.title.rawValue)
            
            // Row 2: INPUT
            Button(action: action) {
                
                VStack {
                    
                    HStack(spacing: 5) {
                                                
                        Text(date.toDayMonthFormat(locale: locale.identifier))

                        Text(
                            date.toYearFormat(
                                locale: locale.identifier,
                                isLongYear: !dimensions.isSmallDevice
                            )
                        )
                        
                    } //: HStack
                    .textStyle(
                        foregroundColor: .onSurface,
                        font: .semibold,
                        size: 17
                    )
                    
                } //: VStack
                .fillMaxWidth()
                .frame(height: 53)
                .background(Colors.onSurfaceDark.color)
                .clipShape(
                    RoundedRectangle(cornerRadius: 15)
                )
                
            } //: Button
            .buttonStyle(ScaleButtonStyle())
            .accessibilityLabel(String("\(title) Button"))

        } //: VStack
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct DateInputView_Previews: PreviewProvider {
    static var previews: some View {
        DateInputView(
            date: Date(),
            title: "TITLE",
            action: {}
        )
        .environment(\.locale, .simplifiedChinese)
        .previewLayout(.sizeThatFits)
        .padding()
        .frame(width: 184)
    }
}
