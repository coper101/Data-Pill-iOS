//
//  PillTitleView.swift
//  Data Pill
//
//  Created by Wind Versi on 13/1/23.
//

import SwiftUI

struct PillTitleView: View {
    // MARK: - Props
    @Namespace private var animation

    var date: Date
    var percentage: Int
    var showPercentage: Bool
    
    var hasShadow = true
    var color = Colors.onSecondary
    
    var usageType: ToggleItem
    
    // MARK: - UI
    var textLabel: some View {
        Text(getPillTitle(with: usageType, on: date))
            .textStyle(
                foregroundColor: color,
                font: .semibold,
                size: 20
            )
            .matchedGeometryEffect(id: "usageType", in: animation)
            .transition(.opacity.animation(.easeOut(duration: 0.7)))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            // Col 1: PERCENTAGE
            if showPercentage {
                
                Text(verbatim: "\(percentage)%")
                    .textStyle(
                        foregroundColor: color,
                        font: .semibold,
                        size: 20
                    )
                    .opacity(0.5)
                
            }
            
            // Col 2: TODAY or DATE
            Spacer()
            
            Group {
                
                if usageType == .plan {
                    textLabel
                } else {
                    textLabel
                }
                
            }
            .`if`(hasShadow) { view in
                view
                    .shadow(
                        color: .black.opacity(0.1),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            }
            
        } //: HStack
        .padding(.horizontal, 18)
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct PillTitleView_Previews: PreviewProvider {
    static var todaysDate = Date()
    
    static var previews: some View {
        Group {
            
            PillTitleView(
                date: todaysDate,
                percentage: 20,
                showPercentage: true,
                usageType: .plan
            )
            .previewDisplayName("Plan / with Percentage")
            
            PillTitleView(
                date: todaysDate,
                percentage: 20,
                showPercentage: false,
                usageType: .plan
            )
            .previewDisplayName("Plan / without Percentage")
            
            PillTitleView(
                date: todaysDate,
                percentage: 20,
                showPercentage: true,
                usageType: .daily
            )
            .previewDisplayName("Daily / with Percentage")
            
            
            PillTitleView(
                date: todaysDate,
                percentage: 20,
                showPercentage: false,
                usageType: .daily
            )
            .previewDisplayName("Daily / without Percentage")
            
            PillTitleView(
                date: Calendar.current.date(
                    byAdding: .day, value: -3, to: todaysDate)!,
                percentage: 20,
                showPercentage: true,
                usageType: .daily
            )
            .previewDisplayName("Daily / Yesterday")
            
            PillTitleView(
                date: todaysDate,
                percentage: 20,
                showPercentage: false,
                hasShadow: false,
                color: .onSurface,
                usageType: .daily
            )
            .previewDisplayName("Daily / Faint Title")
            
            
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.green)
    }
}
