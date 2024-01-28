//
//  ReportABugView.swift
//  Data Pill
//
//  Created by Wind Versi on 20/1/24.
//

public extension View {
    
    func transparentScrolling() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        } else {
            return onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
}

import SwiftUI

struct ReportABugView: View {
    // MARK: - Props
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dimensions) var dimensions: Dimensions
    @State var emailAddress: String = ""
    @State var title: String = ""
    @State var description: String = ""
    @State var screenshots: [Screenshot] = []
    
    @State private var hasTappedSend: Bool = false
    
    var canSend: Bool {
        if emailAddress.isEmpty {
            return false
        }
        if title.isEmpty {
            return false
        }
        if description.isEmpty {
            return false
        }
        if screenshots.isEmpty {
            return false
        }
        return true
    }
    
    func background(isValid: Bool) -> Colors {
        let color: Colors = {
            if !isValid {
                return .error
            } else {
                return .surface
            }
        }()
        return hasTappedSend ? color : .surface
    }
    
    func onBackground(isValid: Bool) -> Colors {
        let color: Colors = {
            if !isValid {
                return .onError
            } else {
                return .onSurfaceLight
            }
        }()
        return hasTappedSend ? color : .onSurfaceLight
    }
    
    func title(isValid: Bool, inputName: String) -> String {
        "\(hasTappedSend && !isValid ? "Enter" : "") \(inputName)"
    }
    
    // MARK: - UI
    var inputs: some View {
        ScrollView {
            
            VStack(spacing: 16) {
                                
                TextField("", text: $emailAddress)
                    .cardStyle(
                        title: title(isValid: !emailAddress.isEmpty, inputName: "Email Address"),
                        titleColor: onBackground(isValid: !emailAddress.isEmpty),
                        background: background(isValid: !emailAddress.isEmpty)
                    )
                
                TextField("", text: $title)
                    .cardStyle(
                        title: title(isValid: !title.isEmpty, inputName: "Title"),
                        titleColor: onBackground(isValid: !title.isEmpty),
                        background: background(isValid: !title.isEmpty)
                    )
                
                TextEditor(text: $description)
                    .transparentScrolling()
                    .cardStyle(
                        title: title(isValid: !description.isEmpty, inputName: "Description"),
                        titleColor: onBackground(isValid: !description.isEmpty),
                        lineLimit: 5, 
                        background: background(isValid: !description.isEmpty)
                    )
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack(spacing: 14) {
                        
                        Button(action: uploadImageAction) {
                            
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Colors.onSurface.color)
                                .opacity(0.08)
                                .frame(width: 124, height: 184)
                                .overlay(
                                    ZStack {
                                        
                                        Circle()
                                            .fill(Colors.secondaryBlue.color)
                                        
                                        Icons.plusIcon.image
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(Colors.surface.color)
                                        
                                    }
                                    .frame(width: 34, height: 34),
                                    alignment: .center
                                )
                            
                        } //: Button
                        
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
                .cardStyle(
                    title: title(isValid: !screenshots.isEmpty, inputName: "Screenshots"),
                    titleColor: onBackground(isValid: !screenshots.isEmpty),
                    contentPadding: false,
                    background: background(isValid: !screenshots.isEmpty)
                )
                
            } //: VStack
            .padding(.top, 21)
            .padding(.horizontal, 12)
            .padding(.bottom, 184)
                        
        } //: ScrollView
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: INPUTS
            inputs
            
            // MARK: ACTION
            VStack(spacing: 18) {
                                    
                Text("We will get back to you once we’ve received your report. We appreciate your support for this app.")
                    .textStyle(
                        foregroundColor: .onSurface,
                        font: .medium,
                        size: 13,
                        lineLimit: nil,
                        lineSpacing: 2,
                        textAlignment: .center
                    )
                    .padding(.horizontal, 2)
                
                Button(action: sendAction) {
                    
                    Text("Send Report Via")
                        .textStyle(
                            foregroundColor: .onSecondary,
                            font: .semibold,
                            size: 16
                        )
                        .fillMaxWidth()
                        .frame(height: 54)
                    
                } //: Button
                .background(Colors.secondaryBlue.color)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
                
            } //: VStack
            .padding(.bottom, dimensions.insets.bottom)
            .padding(.top, 8)
            .padding(.horizontal, 18)
            .background(Colors.background.color)
            
        } //: ZStack
        .fillMaxSize()
    }
    
    // MARK: - Actions
    func sendAction() {
        withAnimation {
            hasTappedSend = true
        }
        guard canSend else {
            return
        }
        // MARK: TODO
    }
    
    func uploadImageAction() {
        // MARK: TODO
    }
}

// MARK: - Preview
struct ReportABugView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
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
            .previewDisplayName("Filled In")
            
            ReportABugView(
                emailAddress: "",
                title: "",
                description: "",
                screenshots: []
            )
            .previewDisplayName("Empty")
        }
        .previewLayout(.sizeThatFits)
        .background(Colors.background.color)
        .environmentObject(TestData.createAppViewModel())
    }
}
