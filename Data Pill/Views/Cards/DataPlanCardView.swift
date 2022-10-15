//
//  DataPlanCardView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/9/22.
//

import SwiftUI

enum EditDataPlan {
    case data
    case dataPlan
}

struct DataPlanCardView: View {
    // MARK: - Props
    var editType: EditDataPlan?
    var startDate: Date
    var endDate: Date
    var numberOfdays: Int
    
    var periodAction: () -> Void
    var dataAmountAction: () -> Void
    var startPeriodAction: () -> Void
    var endPeriodAction: () -> Void
    
    @Binding var dataAmountValue: String
    var dataUnit: Unit = .gb
    var plusDataAction: () -> Void
    var minusDataAction: () -> Void
        
    var periodTitle: String {
        "\(startDate.toDayMonthFormat()) - \(endDate.toDayMonthFormat())".uppercased()
    }
    
    var caption: String {
        editType == nil || editType == .data ?
            "" :
            "\(numberOfdays) Days"
    }
    
    var subtitle: String {
        if let editType = editType {
            switch editType {
            case .data: return "Data"
            case .dataPlan: return "Data Plan"
            }
        }
        return "Data Plan"
    }
    
    // MARK: - UI
    var dataPlan: some View {
        HStack(spacing: 15) {
            DateInputView(
                date: startDate,
                title: "From",
                action: startPeriodAction
            )
            DateInputView(
                date: endDate,
                title: "To",
                action: endPeriodAction
            )
        } //: HStack
        .fillMaxWidth()
        .padding(.top, 10)
    }
    
    var data: some View {
        StepperView(
            value: $dataAmountValue,
            unit: .gb,
            minusAction: minusDataAction,
            plusAction: plusDataAction
        )
        .padding(.top, 20)
    }
    
    var body: some View {
        ItemCardView(
            style: .wide,
            subtitle: subtitle,
            caption: caption,
            hasBackground: editType == nil,
            textColor: editType == nil ? .onSurfaceLight2 : .onBackground
        ) {
            
            if let editType = editType {
                
                switch editType {
                case .data: data
                case .dataPlan: dataPlan
                }
                
            } else {
                
                // Row 1: PERIOD
                NavRowView(
                    title: periodTitle,
                    subtitle: "\(numberOfdays) Days",
                    action: periodAction
                )
                .padding(.top, 10)
                
                DividerView()
                    .padding(.vertical, 5)
                
                // Row 2: DATA AMOUNT
                NavRowView(
                    title: "\(dataAmountValue) \(dataUnit.rawValue)",
                    subtitle: "",
                    action: dataAmountAction
                )
                
            } // if-else
            
        } //: ItemCardView
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct DataPlanCardView_Previews: PreviewProvider {
    static var appViewModel: AppViewModel = .init()
    
    static var previews: some View {
        DataPlanCardView(
            startDate: appViewModel.startDate,
            endDate: appViewModel.endDate,
            numberOfdays: appViewModel.numOfDaysOfPlan,
            periodAction: {},
            dataAmountAction: {},
            startPeriodAction: {},
            endPeriodAction: {},
            dataAmountValue: .constant("10"),
            plusDataAction: {},
            minusDataAction: {}
        )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Information")
            .padding()
        
        DataPlanCardView(
            editType: .data,
            startDate: appViewModel.startDate,
            endDate: appViewModel.endDate,
            numberOfdays: appViewModel.numOfDaysOfPlan,
            periodAction: {},
            dataAmountAction: {},
            startPeriodAction: {},
            endPeriodAction: {},
            dataAmountValue: .constant("10"),
            plusDataAction: {},
            minusDataAction: {}
        )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Edit Data")
            .padding()
        
        DataPlanCardView(
            editType: .dataPlan,
            startDate: appViewModel.startDate,
            endDate: appViewModel.endDate,
            numberOfdays: appViewModel.numOfDaysOfPlan,
            periodAction: {},
            dataAmountAction: {},
            startPeriodAction: {},
            endPeriodAction: {},
            dataAmountValue: .constant("10"),
            plusDataAction: {},
            minusDataAction: {}
        )
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Edit Data Plan")
            .padding()
    }
}

