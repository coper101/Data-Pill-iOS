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

struct BasePillView<Label, FaintLabel>: View where Label: View, FaintLabel: View {
    // MARK: - Props
    @Namespace private var animation

    var percentage: Int
    
    var isContentShown = true
    var fillLineTitle: LocalizedStringKey? = nil
    var fillLineTitleCharCount = 0
    var hasPillOutline = false /// for tracking pill outline
    var orientation = PillOrientation.vertical
    
    var hasBackground: Bool
    var backgroundColor = Colors.surface
    var backgroundOpacity = 1.0
    var color: Color
    
    var widthScale: CGFloat = 0.45
    var customSize: CGSize? = nil
    
    @ViewBuilder var label: Label
    @ViewBuilder var faintLabel: FaintLabel
    
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
    
    var fillLineYOffset: CGFloat {
        let titleTopPadding: CGFloat = 5
        return height - ( (CGFloat(percentage) / 100) * height) - titleTopPadding
    }
    
    var paddingTop: CGFloat {
        // ensure pill title is seen
        (percentage > 90) ? 80 : 10
    }
    
    var cornerRadius: CGFloat {
        (width < 200) ? 2 : 5
    }
            
    // MARK: - UI
    var verticalPill: some View {
        ZStack {
            
            // Layer 1: FILL COLOR
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)
            
            // Layer 2: SHINE
            LinearGradient(
                colors: [
                    .white.opacity(0.25),
                    .white.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .matchedGeometryEffect(id: "Fill", in: animation)
            
            // Layer 3: LABEL
            label
                .fillMaxHeight(alignment: .top)
                .padding(.top, paddingTop)
                .matchedGeometryEffect(id: "Label", in: animation)
             
        } //: ZStack
        .frame(
            height: (CGFloat(percentage) / 100) * height
        )
        .compositingGroup()
    }
    
    var horizontalPill: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(color)
            .frame(
                width: (CGFloat(percentage) / 100) * width
            )
    }
    
    var body: some View {
        ZStack(alignment: (orientation == .vertical) ? .bottom : .leading) {
                        
            // Layer 1: PILL SHAPE BACKGROUND
            backgroundColor.color
                .opacity(hasBackground ? backgroundOpacity : 0)
            
            // Layer 2: FAINT LABEL (when title gets clipped off)
            // faintLabel
            //    .fillMaxHeight(alignment: .bottom)
            //    .padding(.bottom, 0.07 * height)
            
            // Layer 3: PERCENTAGE FILL
            if isContentShown && fillLineTitle == nil {
                switch orientation {
                case .horizontal:
                    horizontalPill
                case .vertical:
                    verticalPill
                }
            } //: if
            
            // Layer 4: FILL LINE
            if let fillLineTitle {
                FillLineView(
                    title: fillLineTitle,
                    titleCharCount: fillLineTitleCharCount
                )
                .offset(y: fillLineYOffset)
            }
            
        } //: ZStack
        .frame(width: width, height: height)
        .clipShape(
            Capsule(style: .circular)
        )
        .`if`(hasPillOutline) { view in
            // Layer 5: PILL OUTLINE
            view
                .background(
                    Capsule(style: .circular)
                        .stroke(Colors.onSurfaceLight2.color, lineWidth: 1)
                )
        }
        .`if`(fillLineTitle != nil) { view in
            // Layer 6: FILL LINE (for title that is hidden when get clipped by border)
            view
                .overlay(
                    FillLineView(
                        title: fillLineTitle!,
                        titleCharCount: fillLineTitleCharCount,
                        isLineShown: false
                    )
                        .offset(y: fillLineYOffset)
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
                    color: Colors.secondaryBlue.color,
                    customSize: (orientation == .vertical) ?
                        .init(width: 230, height: 500) :
                        .init(width: 100, height: 30),
                    label: {},
                    faintLabel: {}
                )
                .previewDisplayName("\(orientation.id) Pill")
                
                if orientation == .vertical {
                    BasePillView(
                        percentage: 20,
                        fillLineTitle: "Today",
                        fillLineTitleCharCount: "Today".count,
                        orientation: orientation,
                        hasBackground: true,
                        color: Colors.secondaryBlue.color,
                        label: {},
                        faintLabel: {}
                    )
                    .previewDisplayName("History Lines")
                }
                
            } //: ForEach
            
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
