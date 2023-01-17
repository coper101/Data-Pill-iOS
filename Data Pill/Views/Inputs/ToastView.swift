//
//  ToastView.swift
//  Data Pill
//
//  Created by Wind Versi on 28/12/22.
//

import SwiftUI

struct ToastView: View {
    // MARK: - Props
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var message: LocalizedStringKey
    
    // MARK: - UI
    var body: some View {
        HStack(spacing: 5) {
                    
            // Col 1: ICON
            Spacer()
            Icons.warningIcon.image
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(Colors.onSurface.color)
            
            // Col 2: MESSAGE
            Text(
                message,
                comment: "Toast error message"
            )
                .textStyle(
                    foregroundColor: .onSurface,
                    font: .semibold,
                    size: 14,
                    lineLimit: 2,
                    textAlignment: .center
                )
            Spacer()
            
        } //: HStack
        .padding(.vertical, 8)
        .background(Colors.background.color)
        .clipShape(
            RoundedRectangle(cornerRadius: 15)
        )
        .cardShadow(scheme: colorScheme)
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView(
            message: "Exceeds maximum data amount"
        )
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.green)
    }
}
