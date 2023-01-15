//
//  FillLineView.swift
//  Data Pill
//
//  Created by Wind Versi on 4/12/22.
//

import SwiftUI

struct FillLineView: View {
    // MARK: - Props
    var title: LocalizedStringKey
    var titleCharCount: Int
    var isLineShown = true
    
    var isLongTitle: Bool {
        titleCharCount > 3
    }
    
    // MARK: - UI
    var line: some View {
        Rectangle()
            .fill(Colors.onBackgroundLight.color)
            .frame(height: 1)
            .padding(.top, 5)
            .opacity(isLineShown ? 1 : 0)
    }
    
    var text: some View {
        Text(title)
            .kerning(1)
            .textStyle(
                foregroundColor: .onBackgroundLight,
                font: .bold,
                size: 18
            )
            .shadow(color: Colors.surface.color, radius: 0.5)
    }
    
    var body: some View {
        GeometryReader { reader in
            
            let width = reader.size.width
            
            HStack(alignment: .top, spacing: 0) {
                
                // Col 1: LINE
                line
                    .frame(width: width * (isLongTitle ? 0.4 : 0.5))
                
                // Col 2: TITLE
                ZStack {
                    
                    ForEach(1..<5, id: \.self) { _ in
                        text
                    }
                    
                } //: ZStack
                .frame(width: width * (isLongTitle ? 0.5 : 0.4))
                
                // Col 3: LINE
                line
                    .frame(width: width * 0.1)

                
            } //: HStack
            .fillMaxWidth()
             
        } //: GeometryReader
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct FillLineView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            
            FillLineView(
                title: "Today",
                titleCharCount: "Today".count
            )
            .previewDisplayName("Today")
            
            FillLineView(
                title: "Mon",
                titleCharCount: "Mon".count
            )
            .previewDisplayName("Mon")

        }
        .previewLayout(.sizeThatFits)
        .padding()
        .frame(width: 200, height: 50)
        .background(Color.green)
    }
}
