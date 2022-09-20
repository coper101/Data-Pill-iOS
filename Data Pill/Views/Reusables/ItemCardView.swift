//
//  ItemCardView.swift
//  Data Pill
//
//  Created by Wind Versi on 18/9/22.
//

import SwiftUI

enum ItemCardStyle: String, Identifiable, CaseIterable {
    case wide
    case mini
    case mini2 = "mini 2"
    var fontSize: Int {
        switch self {
        case .wide: return 24
        case .mini: return 16
        case .mini2: return 20
        }
    }
    var id: String {
        self.rawValue
    }
    var letterSpacing: Double {
        switch self {
        case .wide: return 0
        case .mini: return 3.25
        case .mini2: return 0
        }
    }
    var allCaps: Bool {
        switch self {
        case .wide: return false
        case .mini: return true
        case .mini2: return false
        }
    }
    var type: SFProText {
        switch self {
        case .wide: return .semibold
        case .mini: return .bold
        case .mini2: return .semibold
        }
    }
    var lineLimit: Int {
        switch self {
        case .wide: return 1
        case .mini: return 1
        case .mini2: return 2
        }
    }
}

struct ItemCardView<Content>: View where Content: View {
    // MARK: - Props
    var style: ItemCardStyle
    var subtitle: String
    var verticalSpacing: CGFloat = 0
    var navigateAction: () -> Void = {}
    var width: CGFloat? = nil
    @ViewBuilder var content: () -> Content
        
    // MARK: - UI
    var label: some View {
        Text(style.allCaps ? subtitle.uppercased() : subtitle)
            .kerning(style.letterSpacing)
            .textStyle(
                foregroundColor: .onSurfaceLight2,
                font: style.type,
                size: style.fontSize,
                lineLimit: style.lineLimit
            )
    }
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: verticalSpacing
        ) {
            if (style == .wide) {
                
                // Row 1: LABEL
                label
                
                // Row 2: CONTENT
                content()
                
            } else {
                
                // Row 1: CONTENT
                content()

                // Row 2: LABEL
                HStack(
                    alignment: .bottom,
                    spacing: 0
                ) {
                    
                    // Col 1: SUBTITLE
                    label
                    
                    // Col 2: ICON
                    if (style == .mini2) {
                        Spacer()
                        Button(action: navigateAction) {
                            Icons.navigateIcon.image
                                .resizable()
                                .size(length: 26)
                                .foregroundColor(
                                    Colors.onSurfaceLight2.color
                                )
                        }
                    }
                    
                } //: HStack
                
            } //: if-else
            
        } //: VStack
        .if(width != nil) { view in
            view.frame(
                width: width,
                alignment: .leading
            )
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(Colors.surface.color)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct ItemCardView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ItemCardStyle.allCases) { style in
            ItemCardView(
                style: style,
                subtitle: "Subtitle Subtitle Subtitle",
                width: 150
            ) {
                Text("").frame(height: 50)
            }
            .previewLayout(.sizeThatFits)
            .previewDisplayName(
                displayName(
                    "Item Card",
                    style.id.firstCap()
                )
            )
            .padding()
        }
    }
}
