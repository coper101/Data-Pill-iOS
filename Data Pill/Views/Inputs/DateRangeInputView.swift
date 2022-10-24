//
//  DateRangeInputView.swift
//  Data Pill
//
//  Created by Wind Versi on 15/10/22.
//

import SwiftUI

struct DateRangeInputView: View {
    // MARK: - Props
    @Environment(\.dimensions) var dimensions: Dimensions
    @Binding var selectionDate: Date
    
    var fromDateRange: PartialRangeFrom<Date>?
    var toDateRange: PartialRangeThrough<Date>?
    
    // MARK: - UI
    var body: some View {
        Group {
            
            if let toDateRange = toDateRange {
                
                DatePicker(
                    selection: $selectionDate,
                    in: toDateRange,
                    displayedComponents: .date,
                    label: {}
                )
                
            } else {
                
                DatePicker(
                    selection: $selectionDate,
                    in: fromDateRange!,
                    displayedComponents: .date,
                    label: {}
                )
                
            } //: if-else
            
        } //: Group
        .preferredColorScheme(.light)
        .datePickerStyle(.graphical)
        .frame(width: dimensions.screen.width * 0.9)
        .scaleEffect(0.9)
        .background(
            Colors.background.color
                .clipShape(RoundedRectangle(cornerRadius: 10))
        )
        .padding(.top, dimensions.insets.top + 14)
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct DateRangeInputView_Previews: PreviewProvider {
    static var todaysDate = Date()
    
    static var previews: some View {
        DateRangeInputView(
            selectionDate: .constant(todaysDate),
            fromDateRange: todaysDate.fromDateRange(),
            toDateRange: todaysDate.toDateRange()
        )
            .previewLayout(.sizeThatFits)
            // .background(Colors.Background)
    }
}
