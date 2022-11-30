//
//  WidgetPillView.swift
//  Data Pill
//
//  Created by Wind Versi on 27/11/22.
//

import SwiftUI

struct WidgetPillView: View {
    // MARK: - Props
    var usedData: Double
    var maxData: Double
    var dataUnit: Unit
    var subtitle: String
    var color: Colors
    
    var percentageUsed: Int {
        usedData.toPercentage(with: maxData)
    }
    
    var data: String {
        "\(usedData.toDp(n: 2)) / \(maxData.toDp(n: 2))"
    }
    
    // MARK: - UI
    var body: some View {
        GeometryReader { reader in
            let height = reader.size.height
            
            HStack(
                alignment: .center,
                spacing: 0
            ) {
                
                // Col 1: PILL
                BasePillView(
                    percentage: percentageUsed,
                    isContentShown: true,
                    hasBackground: true,
                    color: color,
                    widthScale: 0,
                    customSize: .init(
                        width: 56,
                        height: height * 0.9
                    ),
                    label: {}
                )
                
                Spacer()
                
                // Col 2: INFO
                VStack(
                    alignment: .trailing,
                    spacing: 0
                ) {
                    
                    // Row 1: DATA USED IN PERCENTAGE
                    Text("\(percentageUsed)%")
                        .textStyle(
                            foregroundColor: .onSurface,
                            font: .semibold,
                            size: 23,
                            lineLimit: 1
                        )
                        .padding(.top, 7)
                                    
                    // Row 2: DATA USED
                    Text(data)
                        .textStyle(
                            foregroundColor: .onSurface,
                            font: .semibold,
                            size: 12,
                            lineLimit: 1
                        )
                        .opacity(0.5)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    // Row 2: SUBTITLE
                    Text(subtitle.uppercased())
                        .kerning(2.0)
                        .textStyle(
                            foregroundColor: Colors.onSurfaceLight2,
                            font: .bold,
                            size: (subtitle.count <= 3) ? 16 : 13
                        )
                        .padding(.bottom, 4)
                    
                } //: VStack
                 
            } //: HStack
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .fillMaxSize()
            .background(Colors.background.color)
            
        } //: GeometryReader
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct WidgetPillView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetPillView(
            usedData: 0.1,
            maxData: 1,
            dataUnit: .gb,
            subtitle: "Mon",
            color: .secondaryBlue
        )
            .previewLayout(.sizeThatFits)
            .frame(width: 148, height: 148)
    }
}
