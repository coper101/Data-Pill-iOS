//
//  NonPlanView.swift
//  Data Pill
//
//  Created by Wind Versi on 3/1/23.
//

import SwiftUI

struct NonPlanView: View {
    // MARK: - Props
    @State private var titleOpacity = 0.2
    @State private var descriptionOpacity = 0.2
    @State private var buttonOpacity = 0.5
    
    var startAction: Action
    
    // MARK: - UI
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 28
        ) {
            
            // Row 1:
            Text("Nope.")
                .textStyle(
                    foregroundColor: .onBackground,
                    font: .semibold,
                    size: 20
                )
                .opacity(titleOpacity)
                .animation(
                    .easeIn(duration: 0.5),
                    value: titleOpacity
                )
            
            // Row 2:
            VStack(
                alignment: .leading,
                spacing: 19
            ) {
                
                Text("Data Pill will just monitor and track your daily mobile data.")
                
                Text("If you ever subscribe to a plan in the future, toggle Data Plan.")
                    
            } //: VStack
            .textStyle(
                foregroundColor: .onBackground,
                font: .semibold,
                size: 20,
                lineLimit: 10,
                lineSpacing: 3
            )
            .opacity(descriptionOpacity)
            .animation(
                .easeIn(duration: 0.5),
                value: descriptionOpacity
            )
           
            // Row 3:
            Spacer()

            ButtonView(
                type: .start,
                fullWidth: true
            ) { _ in
                startAction()
            }
            .fillMaxWidth()
            .opacity(buttonOpacity)
            .animation(
                .easeIn(duration: 0.5),
                value: buttonOpacity
            )
            
        } //: VStack
        .onAppear {
            titleOpacity = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                descriptionOpacity = 1.0
                titleOpacity = 0.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                buttonOpacity = 1.0
                descriptionOpacity = 0.2
            }
        }
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct NonPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NonPlanView(startAction: {})
            .previewLayout(.sizeThatFits)
    }
}
