//
//  SpinnerView.swift
//  Data Pill
//
//  Created by Wind Versi on 5/3/23.
//

import SwiftUI

struct SpinnerView: View {
    // MARK: - Props
    @State private var isAnimating: Bool = false
    
    // MARK: - UI
    var body: some View {
        ZStack {
            
            // BASE
            Circle()
                .stroke(Colors.surface.color, lineWidth: 1.80)
                .frame(width: 16, height: 16)
         
            // SPIN INDICATOR
            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(Colors.onSurfaceLight.color, lineWidth: 1.80)
                .frame(width: 16, height: 16)
                .rotationEffect(.init(degrees: isAnimating ? 360 : 0) )
            
            
        } //: ZStack
        .onAppear(perform: didAppear)
    }
    
    // MARK: - Actions
    func didAppear() {
        withAnimation(
            .linear(duration: 0.8)
            .repeatForever(autoreverses: false)
        ) {
            isAnimating = true
        }
    }
}

// MARK: - Preview
struct SpinnerView_Previews: PreviewProvider {
    static var previews: some View {
        SpinnerView()
            .previewLayout(.sizeThatFits)
            .padding()
            .background(Color.green)
    }
}
