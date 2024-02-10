//
//  EditDataUnitView.swift
//  Data Pill
//
//  Created by Wind Versi on 9/2/24.
//

import SwiftUI

struct EditDataUnitView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    
    var description: String {
        "e.g. \(appViewModel.dataUsed)"
    }
    
    // MARK: - UI
    var body: some View {
        ScrollView {
            
            VStack(alignment: .leading, spacing: 14) {
                
                VStack(spacing: 0) {
                    
                    SettingsRowView(title: "GB", hasDivider: true) {
                        
                        RadioButtonView(
                            isSelected: appViewModel.unit == .gb,
                            action: { unitTypeAction(type: .gb) }
                        )
                        .padding(.vertical, 4)
                        .transition(.scale)
                    }
                    
                    SettingsRowView(title: "MB") {
                        
                        RadioButtonView(
                            isSelected: appViewModel.unit == .mb,
                            action: { unitTypeAction(type: .mb) }
                        )
                        .padding(.vertical, 4)
                        .transition(.scale)
                    }
                    
                } //: VStack
                .rowSection(title: nil)
                .padding(.top, 34)
                
                Text(description)
                    .textStyle(
                        foregroundColor: .onSurfaceLight,
                        size: 14
                    )
                
            } //: VStack
            .padding(.horizontal, 24)

        } //: ScrollView
    }
    
    // MARK: - Actions
    func unitTypeAction(type: Unit) {
        withAnimation {
            appViewModel.didEditUnit(unit: type)
        }
    }
}

// MARK: - Preview
struct EditDataUnitView_Previews: PreviewProvider {
    static var previews: some View {
        EditDataUnitView()
            .previewLayout(.sizeThatFits)
            .environmentObject(TestData.createAppViewModel())
    }
}
