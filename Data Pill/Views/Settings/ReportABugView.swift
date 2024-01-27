//
//  ReportABugView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/1/24.
//

import SwiftUI

struct ReportABugView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    @State var emailAddress: String = ""
    @State var title: String = ""
    @State var description: String = ""
    @State var screenshots: [Screenshot] = []
    
    // MARK: - UI
    var inputs: some View {
        ScrollView {
            
            VStack(spacing: 16) {
                                
                TextField("", text: $emailAddress)
                    .cardStyle(title: "Email Address")
                
                TextField("", text: $title)
                    .cardStyle(title: "Title")
                
                TextField("", text: $description)
                    .cardStyle(
                        title: "Description",
                        lineLimit: 5
                    )
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 14) {
                        
                        ForEach(screenshots) { screenshot in
                            
                            Image(uiImage: screenshot.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 124, height: 184)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                        } //: ForEach
                        
                    } //: HStack
                    .padding(.top, 8)
                    .padding(.horizontal, 14)
                    
                } //: ScrollView
                .cardStyle(title: "Screenshot", contentPadding: false)

            } //: VStack
            .padding(.vertical, 21)
            .padding(.horizontal, 18)
                        
        } //: ScrollView
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: INPUTS
            inputs
            
            // MARK: ACTION
            Button(action: sendAction) {
                
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
            .padding(.horizontal, 18)
            
        } //: ZStack
        .fillMaxSize()
    }
    
    // MARK: - Actions
    func sendAction() {
        
    }
}

// MARK: - Preview
struct ReportABugView_Previews: PreviewProvider {
    static var previews: some View {
        ReportABugView(
            emailAddress: "example@mail.com",
            title: "Widget Not Working",
            description: "When I was...",
            screenshots: [
                .init(image: .testImage),
                .init(image: .testImage),
                .init(image: .testImage)
            ]
        )
        .previewLayout(.sizeThatFits)
        .background(Colors.background.color)
        .environmentObject(TestData.createAppViewModel())
    }
}
