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

enum PillOrientation: String, CaseIterable, Identifiable {
    case horizontal = "Horizontal"
    case vertical = "Vertical"
    var id: String {
        self.rawValue
    }
}

struct BasePillView<Label>: View where Label: View {
    // MARK: - Props
    var percentage: Int
    
    var isContentShown: Bool = true
    var fillLine: FillLine? = nil
    var orientation: PillOrientation = .vertical
    
    var hasBackground: Bool
    var backgroundColor: Colors = .surface
    var backgroundOpacity: Double = 1
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
    
    var height: CGFloat {
        if let customSize = customSize {
            return customSize.height
        }
        return (screenWidth * widthScale) * 2.26
    }
    
    var paddingTop: CGFloat {
        (percentage > 90) ? 50 : 10
    }
    
    var cornerRadius: CGFloat {
        (width < 200) ? 2 : 5
    }
        
    var verticalPill: some View {
        ZStack {
            
            // Layer 1: FILL COLOR
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color.color)
            
            // Layer 2: SHINE
            LinearGradient(
                colors: [
                    .white.opacity(0.25),
                    .white.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Layer 3: LABEL
            label
                .fillMaxHeight(alignment: .top)
                .padding(.top, paddingTop)
             
        } //: ZStack
        .frame(
            height: (CGFloat(percentage) / 100) * height
        )
    }
    
    var horizontalPill: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(color.color)
            .frame(
                width: (CGFloat(percentage) / 100) * width
            )
    }
    
    // MARK: - UI
    var body: some View {
        ZStack(alignment: orientation == .vertical ? .bottom : .leading) {
            
            // Layer 1: PILL SHAPE BACKGROUND
            backgroundColor.color
                .opacity(hasBackground ? backgroundOpacity : 0)
            
            // Layer 2: PERCENTAGE FILL
            if isContentShown && fillLine == nil {
                switch orientation {
                case .horizontal:
                    horizontalPill
                case .vertical:
                    verticalPill
                }
            } //: if
            
            if let fillLine = fillLine {
                let titleTopPadding: CGFloat = 5
                FillLineView(title: fillLine.title)
                    .offset(y: height - ( (CGFloat(percentage) / 100) * height) - titleTopPadding)
            }
            
        } //: ZStack
        .frame(
            width: width,
            height: height
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
            
            ForEach(PillOrientation.allCases) { orientation in
                
                BasePillView(
                    percentage: 50,
                    isContentShown: true,
                    orientation: orientation,
                    hasBackground: true,
                    color: .secondaryBlue,
                    customSize: (orientation == .vertical) ?
                        .init(width: 230, height: 500) :
                        .init(width: 100, height: 30),
                    label: {}
                )
                .previewDisplayName("\(orientation.id)")
                
                if orientation == .vertical {
                    BasePillView(
                        percentage: 20,
                        fillLine: .init(title: "Today"),
                        orientation: orientation,
                        hasBackground: true,
                        color: .secondaryBlue,
                        label: {}
                    )
                    .previewDisplayName("History Lines")
                }
                
            } //: ForEach
            
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
