//
//  AutoPeriodCardView.swift
//  Data Pill
//
//  Created by Wind Versi on 19/9/22.
//

import SwiftUI

struct AutoPeriodCardView: View {
    // MARK: - Props
    @Binding var isAuto: Bool
    var width: CGFloat
    
    // MARK: - UI
    var body: some View {
        ItemCardView(
            style: .mini,
            subtitle: "PERIOD",
            verticalSpacing: 5,
            width: width
        ) {
            Button(action: didTapToggle) {
                Text(isAuto ? "Auto" : "Manual")
                    .textStyle(
                        foregroundColor: .onSurface,
                        font: .bold,
                        size: 20,
                        maxWidth: .infinity
                    )
                    .opacity(isAuto ? 1 : 0.5)
                    .id(isAuto ? "Auto" : "Manual")
                    .transition(.opacity)
                    .padding(.bottom, 10)
            }
            .buttonStyle(ScaleButtonStyle())
            .fillMaxWidth()
        } //: ItemCardView
        .accessibilityIdentifier("period")
    }
    
    // MARK: - Actions
    func didTapToggle() {
        withAnimation(.easeIn(duration: 0.2)) {
            isAuto.toggle()
        }
    }
}

// MARK: - Preview
struct AutoPeriodCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AutoPeriodCardView(
                isAuto: .constant(true),
                width: 150
            )
            AutoPeriodCardView(
                isAuto: .constant(false),
                width: 150
            )
        }
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
