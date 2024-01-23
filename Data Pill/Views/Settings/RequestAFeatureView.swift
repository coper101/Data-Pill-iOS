//
//  RequestAFeatureView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/1/24.
//

import SwiftUI

struct RequestAFeatureView: View {
    // MARK: - Props
    @State private var emailAddress: String = "example@mail.com"
    @State private var title: String = "Pill Customization"
    @State private var description: String = "I really want this..."
    @State private var screenshots: [Screenshot] = []
    
    // MARK: - UI
    var body: some View {
        ScrollView {
            
            VStack(spacing: 12) {
                
                
                TextField("", text: $emailAddress)
                    .textFieldStyle(title: "Email Address")
                
                TextField("", text: $title)
                    .textFieldStyle(title: "Title")
                
                TextField("", text: $description)
                    .textFieldStyle(title: "Description", lineLimit: 5)
                
                ScrollView(.horizontal) {
                    
                    HStack(spacing: 12) {
                        
                        ForEach(screenshots) { screenshot in
                            
                            Image(uiImage: screenshot.image)
                                .resizable()
                                .frame(width: 100, height: 450)
                                .scaledToFit()
                            
                        } //: ForEach
                        
                    } //: HStack
                    
                } //: ScrollView
                
            } //: VStack
            .padding(.horizontal, 21)
                        
        } //: ScrollView
    }
    
    // MARK: - Actions
}

// MARK: - Preview
struct RequestAFeature_Previews: PreviewProvider {
    static var previews: some View {
        RequestAFeatureView()
            .previewLayout(.sizeThatFits)
            // .background(Colors.Background)
    }
}
