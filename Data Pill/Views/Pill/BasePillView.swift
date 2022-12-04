//
//  BasePillView.swift
//  Data Pill
//
//  Created by Wind Versi on 27/11/22.
//

import SwiftUI

struct FillLine {
    let title: String
}

struct BasePillView<Label>: View where Label: View {
    // MARK: - Props
    var percentage: Int
    
    var isContentShown: Bool = true
    var fillLine: FillLine? = nil
    
    var hasBackground: Bool
    var color: Colors
    
    var widthScale: CGFloat = 0.45
    var customSize: CGSize? = nil
    @ViewBuilder var label: Label
    
    let screenWidth = UIScreen.main.bounds.size.width
    
    var width: CGFloat {
        if let customSize = customSize {
            return customSize.width
        }
        return screenWidth * widthScale
    }
    
    var maxHeight: CGFloat {
        if let customSize = customSize {
            return customSize.height
        }
        return (screenWidth * widthScale) * 2.26
    }
    
    var paddingTop: CGFloat {
        percentage > 90 ?
            50 : 10
    }
    
    // MARK: - UI
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // Layer 1: PILL SHAPE BACKGROUND
            Colors.surface.color.opacity(
                hasBackground ? 1 : 0
            )
            
            // Layer 2: PERCENTAGE FILL
            if isContentShown && fillLine == nil {
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
            
            if let fillLine = fillLine {
                FillLineView(title: fillLine.title)
                    .offset(y: maxHeight - ( (CGFloat(percentage) / 100) * maxHeight) )
            }
            
        } //: ZStack
        .frame(
            width: width,
            height: maxHeight
        )
        .clipShape(
            Capsule(style: .circular)
        )
        .`if`(fillLine != nil) { view in
            view.background(
                Capsule(style: .circular)
                    .stroke(Colors.onSurfaceLight2.color, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct BasePillView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            BasePillView(
                percentage: 20,
                isContentShown: true,
                hasBackground: true,
                color: .secondaryBlue,
                label: {}
            )
            .previewDisplayName("Widget")
            
            BasePillView(
                percentage: 20,
                fillLine: .init(title: "Today"),
                hasBackground: true,
                color: .secondaryBlue,
                label: {}
            )
            .previewDisplayName("History Lines")
            
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
