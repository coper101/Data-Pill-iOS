//
//  ReportABugView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/1/24.
//

import SwiftUI

struct Screenshot: Identifiable {
    let id: String = UUID().uuidString
    let image: UIImage
}

struct ReportABugView: View {
    // MARK: - Props
    @State private var emailAddress: String = "example@mail.com"
    @State private var title: String = "Widget Not Working"
    @State private var description: String = "When I was..."
    @State private var screenshots: [Screenshot] = []
    
    // MARK: - UI
    var inputs: some View {
        ScrollView {
            
            VStack(spacing: 14) {
                
                
                TextField("", text: $emailAddress)
                    .textFieldStyle(title: "Email Address")
                
                TextField("", text: $title)
                    .textFieldStyle(title: "Title")
                
                TextField("", text: $description)
                    .textFieldStyle(title: "Description", lineLimit: 5)
                
                ScrollView(.horizontal) {
                    
                    HStack(spacing: 14) {
                        
                        ForEach(screenshots) { screenshot in
                            
                            Image(uiImage: screenshot.image)
                                .resizable()
                                .frame(width: 100, height: 450)
                                .scaledToFit()
                            
                        } //: ForEach
                        
                    } //: HStack
                    
                } //: ScrollView
                .textFieldStyle(title: "Screenshot")

            } //: VStack
            .padding(.horizontal, 21)
                        
        } //: ScrollView
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: INPUTS
            inputs
            
            // MARK: ACTION
            Button(action: {}) {
                
                Text("Send Report Via")
                    .textStyle(
                        foregroundColor: .onSecondary,
                        font: .semibold,
                        size: 16
                    )
                
            } //: Button
            .fillMaxWidth()
            .frame(height: 54)
            .background(Colors.secondaryBlue.color)
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
            .padding(.horizontal, 21)
            
        } //: ZStack
        .fillMaxSize()
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct ReportABugView_Previews: PreviewProvider {
    static var previews: some View {
        ReportABugView()
            .previewLayout(.sizeThatFits)
            // .background(Colors.Background)
    }
}
