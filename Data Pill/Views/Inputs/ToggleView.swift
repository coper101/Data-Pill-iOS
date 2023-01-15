//
//  ToggleView.swift
//  Data Pill
//
//  Created by Wind Versi on 19/9/22.
//

import SwiftUI

struct ToggleItemView: View {
    // MARK: - Props
    var title: LocalizedStringKey
    var isSelected: Bool
    var action: () -> Void
    
    var opacity: Double {
        isSelected ? 1 : 0.15
    }
    
    var backgroundOpacity: Double {
        isSelected ? 1 : 0
    }
    
    // MARK: UI
    var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(
                    foregroundColor: .onSurface,
                    font: .bold,
                    size: 20
                )
                .frame(height: 35)
                .fillMaxWidth()
                .opacity(opacity)
        } //: Button
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ToggleView: View {
    // MARK: - Props
    @Binding var selectedItem: ToggleItem
    var title1: LocalizedStringKey
    var title2: LocalizedStringKey
    
    // MARK: - UI
    var body: some View {
        ZStack(alignment: .top) {
            
            // MARK: - Layer 1:
            RoundedRectangle(cornerRadius: 10)
                .fill(Colors.onSurfaceDark.color)
                .fillMaxWidth()
                .frame(height: 35)
                .offset(y: selectedItem == .plan ? 0 : (35 + 15))
            
            // MARK: - Layer 2:
            VStack(spacing: 15) {
                
                // Row 1: ITEM 1
                ToggleItemView(
                    title: title1,
                    isSelected: selectedItem == .plan,
                    action: didTapItem1
                )
                
                // Row 1: ITEM 2
                ToggleItemView(
                    title: title2,
                    isSelected: selectedItem == .daily,
                    action: didTapItem2
                )
                    
            } //: VStack

        } //: ZStack
    }
    
    // MARK: - Actions
    func didTapItem1() {
        withAnimation {
            selectedItem = .plan
        }
    }
    
    func didTapItem2() {
        withAnimation {
            selectedItem = .daily
        }
    }
                
}

// MARK: - Preview
struct ToggleView_Previews: PreviewProvider {
    static var previews: some View {
        ToggleView(
            selectedItem: .constant(.plan),
            title1: "Title",
            title2: "Title"
        )
            .frame(width: 108)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
