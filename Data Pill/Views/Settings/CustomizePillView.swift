//
//  CustomizePillView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/1/24.
//

import SwiftUI

struct CustomizeDayColorView: View {
    // MARK: - Props
    var dayColors: [Day: Color]
    var day: Day
    var editAction: (Day, Color) -> Void
    
    // MARK: - UI
    var body: some View {
        ZStack {
            
            Circle()
                .fill(Colors.surface.color)
            
            Circle()
                .fill(dayColors[day] ?? Colors.surface.color)
                .padding(12)
                        
        } //: ZStack
        .frame(width: 54, height: 54)
        .overlay(
            ColorPicker(
                "",
                selection: .init(
                    get: {
                        dayColors[day] ?? Color.white
                    },
                    set: { color in
                        editAction(day, color)
                    }
                )
            )
            .labelsHidden()
            .opacity(0.015)
            .buttonStyle(ScaleButtonStyle())
        )
        .section(
            title: day.shortNameLocalized,
            atTop: false,
            alignment: .center
        )
    }
    
    // MARK: - Actions
}

struct CustomizePillView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dimensions) var dimensions: Dimensions
    
    static let minPercentage = 30
    static let maxPercentage = 60
    
    @State private var todaysUsagePercentageAccumulate: Int = minPercentage
    @State private var todaysUsagePercentageDeduct: Int = maxPercentage
    
    var percentage: Int {
        (appViewModel.fillUsageType == .accumulate) ?
        todaysUsagePercentageDeduct :
        todaysUsagePercentageAccumulate
    }

    // MARK: - UI
    func pillPercentage(day: Day) -> Int {
        switch day {
        case .sunday:
            return 80
        case .monday:
            return 70
        case .tuesday:
            return 60
        case .wednesday:
            return 50
        case .thursday:
            return 40
        case .friday:
            return 30
        case .saturday:
            return 20
        }
    }
    
    var pillPreview: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width * 0.5
            let pillSize = CGSize(width: width - 20, height: width * 2)
            
            HStack(spacing: 0) {
                
                BasePillView(
                    percentage: percentage,
                    isContentShown: true,
                    hasBackground: true,
                    color: appViewModel.todaysColor,
                    customSize: pillSize,
                    label: {
                        if appViewModel.labelsInDaily {
                            
                            Text("TODAY")
                                .textStyle(
                                    foregroundColor: .onSecondary,
                                    font: .semibold,
                                    size: 16
                                )
                                .padding(.horizontal, 14)
                                .fillMaxHeight(alignment: .top)
                                .fillMaxWidth(alignment: .trailing)
                            
                        } //: if
                    },
                    faintLabel: {}
                )
                .section(
                    title: "DAILY",
                    atTop: false,
                    alignment: .center
                )
                
                Spacer()
                
                ZStack {
                    
                    ForEach(Day.allCases) { day in
                        
                        BasePillView(
                            percentage: pillPercentage(day: day),
                            isContentShown: true,
                            hasBackground: false,
                            color: appViewModel.dayColors[day] ?? Colors.secondaryBlue.color,
                            customSize: pillSize,
                            label: {
                                if appViewModel.labelsInWeekly {
                                    
                                    Text(day.shortName.uppercased())
                                        .textStyle(
                                            foregroundColor: .onSecondary,
                                            font: .semibold,
                                            size: 12
                                        )
                                        .padding(.horizontal, 10)
                                        .fillMaxHeight(alignment: .top)
                                        .fillMaxWidth(alignment: .trailing)
                                    
                                } //: if
                            },
                            faintLabel: {}
                        )
                        
                    } //: ForEach
                    
                } //: ZStack
                .section(
                    title: "WEEKLY",
                    atTop: false,
                    alignment: .center
                )
        
            } //: HStack
            
        } //: GeometryReader
        .frame(height: 412)
    }
    
    var colors: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 18) {
                
                ForEach(Day.allCases) { day in
                    
                    CustomizeDayColorView(
                        dayColors: appViewModel.dayColors,
                        day: day,
                        editAction: editDayColorAction
                    )
                    
                } //: ForEach
                
            } //: HStack
            .padding(.horizontal, 21)
                        
        } //: ScrollView
    }
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 0) {
                
                // MARK: PILL PREVIEW
                pillPreview
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                
                // MARK: CUSTOMIZE COLORS
                colors
                
                // MARK: SELECT FILL USAGE
                VStack(spacing: 0) {
                    
                    SettingsRowView(
                        title: "Accumulate",
                        hasDivider: true
                    ) {
                        RadioButtonView(
                            isSelected: appViewModel.fillUsageType == .accumulate,
                            action: { fillUsageTypeAction(type: .accumulate) }
                        )
                        .padding(.vertical, 4)
                    }
                    
                    SettingsRowView(title: "Deduct") {
                        
                        RadioButtonView(
                            isSelected: appViewModel.fillUsageType == .deduct,
                            action: { fillUsageTypeAction(type: .deduct) }
                        )
                        .padding(.vertical, 4)
                        .transition(.scale)
                    }
                    
                } //: VStack
                .rowSection(title: "FILL USAGE")
                .padding(.horizontal, 24)
                .padding(.top, 34)
                
                // MARK: LABELS TOGGLE
                VStack(spacing: 0) {
                    
                    SettingsRowView(
                        title: "In Daily",
                        hasDivider: true
                    ) {
                        SlideToggleView(
                            activeColor: .secondaryBlue,
                            isOn: $appViewModel.labelsInDaily
                        )
                        .padding(.vertical, 4)
                    }
                    
                    SettingsRowView(
                        title: "In Weekly"
                    ) {
                        SlideToggleView(
                            activeColor: .secondaryBlue,
                            isOn: $appViewModel.labelsInWeekly
                        )
                        .padding(.vertical, 4)
                    }
                    
                } //: VStack
                .rowSection(title: "LABELS")
                .padding(.horizontal, 24)
                .padding(.top, 34)

            } //: VStack
            .padding(.bottom, 34)
            
        } //: ScrollView
        .withTopBar(title: "Customize Pill")
    }
    
    // MARK: - Actions
    func editDayColorAction(day: Day, color: Color) {
        withAnimation {
            appViewModel.didEditDayColor(day: day, color: color)
        }
    }
    
    func fillUsageTypeAction(type: FillUsage) {
        withAnimation {
            appViewModel.didTapNewUsageType(type)
        }
    }
}

// MARK: - Preview
struct CustomizePillView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizePillView()
            .previewLayout(.sizeThatFits)
            .environmentObject(TestData.createAppViewModel())
    }
}
