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
    var isPlanActive: Bool
    
    var title: LocalizedStringKey {
        if isPlanActive {
            return isAuto ? "Auto" : "Manual"
        }
        return "NA"
    }
    
    var id: String {
        if isPlanActive {
            return isAuto ? "Auto" : "Manual"
        }
        return "NA"
    }
    
    var opacity: Double {
        if isPlanActive {
            return isAuto ? 1 : 0.5
        }
        return 0.1
    }
    
    // MARK: - UI
    var body: some View {
        ItemCardView(
            style: .mini,
            subtitle: "PERIOD",
            verticalSpacing: 5,
            isToggleOn: .constant(false),
            width: width
        ) {
            
            Button(action: didTapToggle) {
                
                Text(
                    title,
                    comment: "The auto period toggle"
                )
                    .textStyle(
                        foregroundColor: .onSurface,
                        font: .bold,
                        size: 20,
                        maxWidth: .infinity
                    )
                    .opacity(opacity)
                    .id(id)
                    .transition(.opacity)
                    .padding(.bottom, 10)
                
            } //: Button
            .buttonStyle(ScaleButtonStyle())
            .fillMaxWidth()
            .disabled(!isPlanActive)
            
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
                width: 150,
                isPlanActive: true
            )
            .previewDisplayName("Plan / Auto")
            
            AutoPeriodCardView(
                isAuto: .constant(false),
                width: 150,
                isPlanActive: true
            )
            .previewDisplayName("Plan / Manual")

            
            AutoPeriodCardView(
                isAuto: .constant(false),
                width: 150,
                isPlanActive: false
            )
            .previewDisplayName("Non-Plan")

        }
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
