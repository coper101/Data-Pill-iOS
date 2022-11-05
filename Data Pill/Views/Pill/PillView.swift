//
//  PillView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

enum Day: String, CaseIterable {
    case sunday
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

struct DayPill: Identifiable {
    let color: Colors
    let day: Day
    var id: String { self.day.rawValue }
}

struct PillView: View {
    // MARK: - Props
    @Environment(\.dimensions) var dimensions: Dimensions

    var color: Colors = .secondaryBlue
    var percentage: Int
    var date: Date
    var hasBackground = true
    var usageType: ToggleItem
    var widthScale: CGFloat = 0.45
    var isContentShown = true
    
    var width: CGFloat {
        dimensions.screen.width * widthScale
    }
    var maxHeight: CGFloat {
        (dimensions.screen.width * widthScale) * 2.26
    }
    
    var paddingTop: CGFloat {
        percentage > 90 ?
            50 : 10
    }
    var displayedDate: String {
        switch usageType {
        case .plan:
            return "TOTAL"
        case .daily:
            return date.isToday() ?
                "TODAY" :
                date.toDayMonthFormat().uppercased()
        }
    }
    
    // MARK: - UI
    var label: some View {
        HStack(spacing: 0) {
            
            // Col 1: PERCENTAGE
            Text("\(percentage)%")
                .textStyle(
                    foregroundColor: .onSecondary,
                    font: .semibold,
                    size: 20
                )
                .opacity(0.5)
            
            // Col 2: TODAY or DATE
            Spacer()
            Text(displayedDate)
                .textStyle(
                    foregroundColor: .onSecondary,
                    font: .semibold,
                    size: 20
                )
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 4,
                    x: 0,
                    y: 2
                )
            
        } //: HStack
        .padding(.horizontal, 18)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Layer 1:
            Colors.surface.color.opacity(
                hasBackground ? 1 : 0
            )
            
            // Layer 2:
            if isContentShown {
                RoundedRectangle(cornerRadius: 5)
                    .fill(color.color)
                    .frame(
                        height: (CGFloat(percentage) / 100) * maxHeight
                    )
                    .overlay(
                        label
                            .fillMaxHeight(alignment: .top)
                            .padding(.top, paddingTop)
                    )
                    .overlay(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.25),
                                .white.opacity(0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } //: if
            
        } //: ZStack
        .frame(width: width, height: maxHeight)
        .clipShape(Capsule(style: .circular))
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct PillView_Previews: PreviewProvider {
    static var appViewModel: AppViewModel = .init()
    
    static var previews: some View {
        Group {
            
            PillView(
                color: appViewModel.days[0].color,
                percentage: 20,
                date: Date(),
                usageType: .daily
            )
            .previewDisplayName(
                displayName(
                    "Content Shown"
                )
            )
            
            PillView(
                color: appViewModel.days[0].color,
                percentage: 20,
                date: Date(),
                usageType: .daily,
                isContentShown: false
            )
            .previewDisplayName(
                displayName(
                    "Content Hidden"
                )
            )
            
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
