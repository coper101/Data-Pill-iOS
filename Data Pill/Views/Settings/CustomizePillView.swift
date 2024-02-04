//
//  CustomizePillView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/1/24.
//

import SwiftUI

enum FillUsage {
    case accumulate
    case deduct
}

struct CustomizePillView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dimensions) var dimensions: Dimensions
    
    @State private var labelsInWeekly: Bool = true
    @State private var labelsInDaily: Bool = true
    @State private var fillUsageType: FillUsage = .accumulate
    
    var sortedDays: [Day] {
        appViewModel.dayColors.keys.sorted(by: { $0.ordinal() > $1.ordinal() })
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
                    percentage: 30,
                    isContentShown: true,
                    hasBackground: true,
                    color: .secondaryBlue,
                    customSize: pillSize,
                    label: {
                        Text("TODAY")
                            .textStyle(
                                foregroundColor: .onSecondary,
                                font: .semibold,
                                size: 16
                            )
                            .padding(.horizontal, 14)
                            .fillMaxHeight(alignment: .top)
                            .fillMaxWidth(alignment: .trailing)
                    },
                    faintLabel: {}
                )
                .section(
                    title: "Daily",
                    atTop: false,
                    alignment: .center
                )
                
                Spacer()
                
                ZStack() {
                    
                    ForEach(
                        Array(defaultDayColors.keys).sorted(by: { $1.ordinal() > $0.ordinal() }),
                        id: \.rawValue
                    ) { day in
                        
                        BasePillView(
                            percentage: pillPercentage(day: day),
                            isContentShown: true,
                            hasBackground: false,
                            color: defaultDayColors[day] ?? .secondaryBlue,
                            customSize: pillSize,
                            label: {
                                Text(day.shortName.uppercased())
                                    .textStyle(
                                        foregroundColor: .onSecondary,
                                        font: .semibold,
                                        size: 12
                                    )
                                    .padding(.horizontal, 10)
                                    .fillMaxHeight(alignment: .top)
                                    .fillMaxWidth(alignment: .trailing)
                            },
                            faintLabel: {}
                        )
                        
                    } //: ForEach
                    
                } //: ZStack
                .section(
                    title: "Weekly",
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
                
                ForEach(sortedDays, id: \.self) { day in
                    
                    Button(action: { editDayColorAction(day: day) }) {
                        
                        ZStack {
                            
                            Circle()
                                .fill(Colors.surface.color)
                            
                            Circle()
                                .fill(appViewModel.dayColors[day]?.color ?? Color.white)
                                .padding(12)
                            
                        } //: ZStack
                        .frame(width: 54, height: 54)
                      
                    } //: Button
                    .buttonStyle(ScaleButtonStyle())
                    .section(
                        title: day.shortName,
                        atTop: false,
                        alignment: .center
                    )
                    
                } //: ForEach
                
            } //: HStack
                        
        } //: ScrollView
        .padding(.horizontal, 21)
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
                            isSelected: fillUsageType == .accumulate,
                            action: { fillUsageTypeAction(type: .accumulate) }
                        )
                        .padding(.vertical, 4)
                    }
                    
                    SettingsRowView(title: "Deduct") {
                        
                        RadioButtonView(
                            isSelected: fillUsageType == .deduct, 
                            action: { fillUsageTypeAction(type: .deduct) }
                        )
                        .padding(.vertical, 4)
                    }
                    
                } //: VStack
                .rowSection(title: "Fill Usage")
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
                            isOn: $labelsInWeekly
                        )
                        .padding(.vertical, 4)
                    }
                    
                    SettingsRowView(
                        title: "In Weekly"
                    ) {
                        SlideToggleView(
                            activeColor: .secondaryBlue,
                            isOn: $labelsInDaily
                        )
                        .padding(.vertical, 4)
                    }
                    
                } //: VStack
                .rowSection(title: "Labels")
                .padding(.horizontal, 24)
                .padding(.top, 34)

            } //: VStack
            .padding(.bottom, 34)
            
        } //: ScrollView
        .withTopBar(title: "Customize Pill")
    }
    
    // MARK: - Actions
    func editDayColorAction(day: Day) {
        withAnimation {
            
        }
    }
    
    func fillUsageTypeAction(type: FillUsage) {
        withAnimation {
            fillUsageType = type
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
