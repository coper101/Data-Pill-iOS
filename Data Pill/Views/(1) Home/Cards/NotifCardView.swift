//
//  NotifCardView.swift
//  Data Pill
//
//  Created by Wind Versi on 19/9/22.
//

import SwiftUI

struct NotifCardView: View {
    // MARK: - Props
    @Binding var isTurnedOn: Bool
    var width: CGFloat
    
    // MARK: - UI
    var body: some View {
        ItemCardView(
            style: .mini,
            subtitle: "NOTIF",
            verticalSpacing: 5,
            width: width
        ) {
            Button(action: didTapToggle) {
                Text(isTurnedOn ? "ON" : "OFF")
                    .textStyle(
                        foregroundColor: .onSurface,
                        font: .bold,
                        size: 20,
                        maxWidth: .infinity
                    )
                    .opacity(isTurnedOn ? 1 : 0.5)
                    .id(isTurnedOn ? "ON" : "OFF")
                    .transition(.opacity)
                    .padding(.bottom, 10)
            }
            .fillMaxWidth()
        }
    }
    
    // MARK: - Actions
    func didTapToggle() {
        withAnimation(.easeIn(duration: 0.2)) {
            isTurnedOn.toggle()
        }
    }
}

// MARK: - Preview
struct NotifCardView_Previews: PreviewProvider {
    static var previews: some View {
        NotifCardView(
            isTurnedOn: .constant(false),
            width: 150
        )
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
