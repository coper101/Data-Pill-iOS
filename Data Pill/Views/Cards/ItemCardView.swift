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
    var subtitle: LocalizedStringKey
    var caption: LocalizedStringKey? = nil
    
    var verticalSpacing: CGFloat = 0
    var navigateAction: () -> Void = {}
    
    var hasBackground = true
    var hasBlur = false
    var backgroundColor = Colors.surface
    
    @Binding var isToggleOn: Bool
    var hasToggle = false
    
    var contentVertPadding: CGFloat = 14
    var contentHorPadding: CGFloat = 20
    
    var hasNavigateIcon = true
    var width: CGFloat?
    var height: CGFloat?
    
    var textColor: Colors = .onSurfaceLight2
    @ViewBuilder var content: () -> Content
        
    // MARK: - UI
    var label: some View {
        Text(
            subtitle,
            comment: "Card title"
        )
            .kerning(style.letterSpacing)
            .textStyle(
                foregroundColor: textColor,
                font: style.type,
                size: style.fontSize,
                lineLimit: style.lineLimit
            )
    }
    
    var secondaryLabel: some View {
        Group {
            if let caption {
                Text(
                    caption,
                    comment: "Card caption. Displays the number of days"
                )
                    .kerning(style.letterSpacing)
                    .textStyle(
                        foregroundColor: Colors.onSurfaceLight,
                        font: style.type,
                        size: 18,
                        lineLimit: style.lineLimit
                    )
                    .opacity(0.6)
                    .accessibilityLabel(AccessibilityLabels.secondaryLabel.rawValue)
            } else {
                EmptyView()
            }
        }
    }
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: verticalSpacing
        ) {
            // MARK: - Wide (label top)
            if (style == .wide) {
                
                // Label
                HStack(spacing: 0) {
                    label
                    Spacer()
                    secondaryLabel
                    
                    if hasToggle {
                        SlideToggleView(isOn: $isToggleOn)
                    }
                    
                } //: HStack
                
                // Content
                content()
                
            }
            // MARK: - Minis (label down)
            else {
                
                // Content
                content()

                // Label
                HStack(
                    alignment: .bottom,
                    spacing: 0
                ) {
                    
                    // Col 1: SUBTITLE
                    label
                    
                    // Col 2: ICON
                    if (style == .mini2 && hasNavigateIcon) {
                        
                        Spacer()
                        
                        Button(action: navigateAction) {
                            Icons.navigateIcon.image
                                .resizable()
                                .size(length: 26)
                                .foregroundColor(
                                    Colors.onSurfaceLight2.color
                                )
                        } //: Button
                        .buttonStyle(ScaleButtonStyle())
                        
                    } //: if
                    
                } //: HStack
                
            } //: if-else
            
        } //: VStack
        .frame(
            width: width,
            height: height,
            alignment: .leading
        )
        .padding(.vertical, contentVertPadding)
        .padding(.horizontal, contentHorPadding)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor.color)
                .blur(radius: hasBlur ? 100 : 0)
        )
        .shadow(color: Color.clear, radius: 0, x: 0, y: 0)
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct ItemCardView_Previews: PreviewProvider {
    static var previews: some View {

        ItemCardView(
            style: .wide,
            subtitle: "Subtitle Subtitle Subtitle",
            caption: "Caption",
            isToggleOn: .constant(false),
            hasToggle: false,
            width: 150,
            textColor: .onBackground
        ) {
            Text("").frame(height: 50)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName(
            displayName(
                "Item Card",
                ItemCardStyle.wide.id.firstCap(),
                "Editing"
            )
        )
        .padding()
        .background(Color.green)

        ItemCardView(
            style: .wide,
            subtitle: "Subtitle Subtitle Subtitle",
            isToggleOn: .constant(false),
            hasToggle: false,
            width: 150,
            textColor: .onBackground
        ) {
            Text("").frame(height: 50)
        }
        .previewLayout(.sizeThatFits)
        .previewDisplayName(
            displayName(
                "Item Card",
                ItemCardStyle.wide.id.firstCap(),
                "Toggle"
            )
        )
        .padding()
        .background(Color.green)

        ForEach(ItemCardStyle.allCases) { style in
            ItemCardView(
                style: style,
                subtitle: "Subtitle Subtitle Subtitle",
                isToggleOn: .constant(false),
                hasToggle: false,
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
            .background(Color.green)
        }
    }
}
