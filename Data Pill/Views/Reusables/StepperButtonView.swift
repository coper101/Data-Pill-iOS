//
//  StepperButtonView.swift
//  Data Pill
//
//  Created by Wind Versi on 1/10/22.
//

import SwiftUI

enum Operator: String, Identifiable, CaseIterable {
    case minus
    case plus
    var id: String {
        return self.rawValue
    }
}

struct StepperButtonView: View {
    // MARK: - Props
    var `operator`: Operator
    var action: () -> Void
    
    var icon: Icons {
        `operator` == .plus ?
            Icons.plusIcon :
            Icons.minusIcon
    }
    
    // MARK: - UI
    var body: some View {
        Button(action: action) {
            icon.image
                .resizable()
                .padding(15)
                .frame(width: 57, height: 53)
                .foregroundColor(Colors.onSurface.color)
                .background(Colors.onSurfaceDark.color)
                .clipShape(
                    RoundedRectangle(cornerRadius: 15)
                )
        } //: Button
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct StepperButtonView_Previews: PreviewProvider {
    static var previews: some View {
        
        ForEach(Operator.allCases) { `operator` in
            StepperButtonView(
                operator: `operator`,
                action: {}
            )
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName(`operator`.rawValue)
        }
    }
}
