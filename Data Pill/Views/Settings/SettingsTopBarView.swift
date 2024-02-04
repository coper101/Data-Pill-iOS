//
//  SettingsTopBarView.swift
//  Data Pill
//
//  Created by Wind Versi on 4/2/24.
//

import SwiftUI

struct SettingsTopBarModifier: ViewModifier {
    // MARK: - Props
    var title: String
    
    // MARK: - UI
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            
            // MARK: TOP BAR
            SettingsTopBarView(title: title)
            
            // MARK: CONTENT
            content
            
        } //: VStack
        .hideNavigationBar()
    }
}

extension View {
    
    func withTopBar(title: String) -> some View {
        self.modifier(SettingsTopBarModifier(title: title))
    }
}

struct SettingsTopBarView: View {
    // MARK: - Props
    @Environment(\.presentationMode) var presentationMode
    var title: String

    // MARK: - UI
    var body: some View {
        HStack(spacing: 0) {
            
            // MARK: Back
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                
                Icons.navigateIcon.image
                    .resizable()
                    .rotationEffect(.degrees(180))
                    .frame(width: 38, height: 38)
                    .foregroundColor(Colors.secondaryBlue.color)
            } //: Button
            
            // MARK: Title
            Spacer()
            Text(title)
                .textStyle(
                    foregroundColor: .onBackground,
                    size: 18
                )
            
            // MARK: Filler
            Spacer()
            Rectangle()
                .fill(Color.clear)
                .frame(width: 38, height: 38)
            
        } //: HStack
        .frame(height: 58)
        .overlay(
            DividerView(
                color: .onBackgroundLight,
                height: 0.2
            ),
            alignment: .bottom
        )
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct SettingsTopBarView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsTopBarView(title: "Title")
            .previewLayout(.sizeThatFits)
    }
}
