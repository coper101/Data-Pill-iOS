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
    @Environment(\.locale) var locale: Locale

    @State var hasShownStepperTip: Bool = true

    var editType: EditDataPlan? = nil
    var startDate: Date
    var endDate: Date
    var numberOfdays: Int
    
    var periodAction: Action
    var dataAmountAction: Action
    var startPeriodAction: Action
    var endPeriodAction: Action
    
    @Binding var isPlanActive: Bool
    @Binding var dataAmountValue: String
    var dataAmount: Double
    var dataUnit: Unit = .gb
    var activeColor: Colors = .onSurfaceLight
    
    var plusDataAction: Action
    var minusDataAction: Action
    var didChangePlusStepperValue: StepperValueAction
    var didChangeMinusStepperValue: StepperValueAction
    
    var periodSubtitle: LocalizedStringKey {
        "\(String(numberOfdays)) Days" // .prefixDay()
    }
    
    var caption: LocalizedStringKey {
        (editType == nil || editType == .data) ?
            "" : "\(String(numberOfdays)) Days" // .prefixDay()
    }
    
    var subtitle: LocalizedStringKey {
        if let editType = editType {
            switch editType {
            case .data:
                return "Data Amount"
            case .dataPlan:
                return "Period"
            }
        }
        return "Data Plan"
    }
    
    var periodTitle: String {
        let start = "\(startDate.toDayMonthFormat(locale: locale.identifier))"
        let end = "\(endDate.toDayMonthFormat(locale: locale.identifier))"
        return "\(start) - \(end)".uppercased()
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
            plusAction: plusDataAction,
            plusStepperValueAction: didChangePlusStepperValue,
            minusStepperValueAction: didChangeMinusStepperValue
        )
        .fillMaxWidth()
        .padding(.top, 28)
        .padding(.bottom, 12)
        .withStepperTip(hasShownStepperTip: $hasShownStepperTip, isBelow: true)
    }
    
    var body: some View {
        ItemCardView(
            style: .wide,
            subtitle: subtitle,
            caption: caption,
            backgroundColor: editType == nil ? .surface : .background,
            isToggleOn: $isPlanActive,
            hasToggle: editType == nil,
            activeColor: activeColor,
            textColor: editType == nil ? .onSurfaceLight2 : .onBackground
        ) {
            
            if let editType = editType {
                
                switch editType {
                case .data:
                    data
                case .dataPlan:
                    dataPlan
                }
                
            } else {
                
                if isPlanActive {

                    // Row 1: PERIOD
                    NavRowView(
                        title: periodTitle,
                        localizedSubtitle: periodSubtitle,
                        action: periodAction
                    )
                    .accessibilityLabel(AccessibilityLabels.period.rawValue)
                    .padding(.top, 10)

                    DividerView()
                        .padding(.vertical, 5)

                    // Row 2: DATA AMOUNT
                    NavRowView(
                        title: "\(dataAmount) \(dataUnit.rawValue)",
                        subtitle: "",
                        action: dataAmountAction
                    )
                    .accessibilityLabel(AccessibilityLabels.amount.rawValue)

                } else {

                    EmptyView()

                }
                
            } // if-else
            
        } //: ItemCardView
        .accessibilityIdentifier(AccessibilityLabels.dataPlan.rawValue)
        .onAppear(perform: onAppear)
    }
    
    // MARK: - Actions
    func onAppear() {
        withAnimation {
            hasShownStepperTip = false
        }
    }
}

// MARK: - Preview
struct DataPlanCardView_Previews: PreviewProvider {
    static var appViewModel: AppViewModel = TestData.createAppViewModel()
    
    static var previews: some View {
        Group {
            
            DataPlanCardView(
                startDate: appViewModel.startDate,
                endDate: appViewModel.endDate,
                numberOfdays: appViewModel.numOfDaysOfPlan,
                periodAction: {},
                dataAmountAction: {},
                startPeriodAction: {},
                endPeriodAction: {},
                isPlanActive: .constant(false),
                dataAmountValue: .constant("10"),
                dataAmount: 10,
                plusDataAction: {},
                minusDataAction: {},
                didChangePlusStepperValue: { _ in },
                didChangeMinusStepperValue: { _ in }
            )
                .previewDisplayName("Information / Inactive Plan")
            
            DataPlanCardView(
                startDate: appViewModel.startDate,
                endDate: appViewModel.endDate,
                numberOfdays: appViewModel.numOfDaysOfPlan,
                periodAction: {},
                dataAmountAction: {},
                startPeriodAction: {},
                endPeriodAction: {},
                isPlanActive: .constant(true),
                dataAmountValue: .constant("10"),
                dataAmount: 10,
                plusDataAction: {},
                minusDataAction: {},
                didChangePlusStepperValue: { _ in },
                didChangeMinusStepperValue: { _ in }
            )
                .previewDisplayName("Information / Active Plan")
            
            DataPlanCardView(
                editType: .data,
                startDate: appViewModel.startDate,
                endDate: appViewModel.endDate,
                numberOfdays: appViewModel.numOfDaysOfPlan,
                periodAction: {},
                dataAmountAction: {},
                startPeriodAction: {},
                endPeriodAction: {},
                isPlanActive: .constant(false),
                dataAmountValue: .constant("10"),
                dataAmount: 10,
                plusDataAction: {},
                minusDataAction: {},
                didChangePlusStepperValue: { _ in },
                didChangeMinusStepperValue: { _ in }
            )
                .previewDisplayName("Edit Data")
            
            DataPlanCardView(
                editType: .dataPlan,
                startDate: appViewModel.startDate,
                endDate: appViewModel.endDate,
                numberOfdays: appViewModel.numOfDaysOfPlan,
                periodAction: {},
                dataAmountAction: {},
                startPeriodAction: {},
                endPeriodAction: {},
                isPlanActive: .constant(false),
                dataAmountValue: .constant("10"),
                dataAmount: 10,
                plusDataAction: {},
                minusDataAction: {},
                didChangePlusStepperValue: { _ in },
                didChangeMinusStepperValue: { _ in }
            )
                .previewDisplayName("Edit Data Plan")
            
        }
        .previewLayout(.sizeThatFits)
        .environment(\.locale, .simplifiedChinese)
        .padding()
        .background(Color.green)
       
    }
}

