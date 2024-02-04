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
    @Environment(\.dimensions) var dimensions: Dimensions
    @StateObject var keyboardRepository: KeyboardRepository = .init()
    @StateObject var viewModel: ReportABugViewModel
    
    init(viewModel: ReportABugViewModel = .init(inputTitle: "Bug")) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    @State private var hasTappedSend: Bool = false
    
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
    
    func title(
        isValid: Bool,
        inputName: String,
        prefix: String = "Enter",
        suffix: String = ""
    ) -> String {
        "\(hasTappedSend && !isValid ? prefix : "") \(inputName) \(hasTappedSend && !isValid ? suffix : "")"
    }
    
    // MARK: - UI
    var inputs: some View {
        ScrollView {
            
            VStack(spacing: 16) {
                                
                // MARK: TITLE
                TextField("", text: $viewModel.inputTitle)
                    .cardStyle(
                        title: title(
                            isValid: viewModel.isValidTitle,
                            inputName: "Title"
                        ),
                        titleColor: onBackground(isValid: viewModel.isValidTitle),
                        background: background(isValid: viewModel.isValidTitle)
                    )
                
                // MARK: DESCRIPTION
                VStack(alignment: .trailing, spacing: 8) {
                    
                    TextEditor(text: $viewModel.inputDescription)
                        .transparentScrolling()
                        .cardStyle(
                            title: title(
                                isValid: viewModel.isValidDescription,
                                inputName: "Description",
                                prefix: "Enter",
                                suffix: "with min. of \(viewModel.inputDescriptionMinChar) Characters"
                            ),
                            titleColor: onBackground(isValid: viewModel.isValidDescription),
                            lineLimit: 5,
                            background: background(isValid: viewModel.isValidDescription)
                        )
                    
                    Text("Min: \(viewModel.inputDescriptionMinChar) Characters")
                        .textStyle(
                            foregroundColor: .onSurfaceLight,
                            font: .medium,
                            size: 12,
                            lineLimit: nil,
                            lineSpacing: 2,
                            textAlignment: .center
                        )
                }
                
                // MARK: SCREENSHOTS
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
                        
                        ForEach(viewModel.inputScreenshots) { screenshot in
                            
                            ZStack(alignment: .topTrailing) {
                                                   
                                Image(uiImage: screenshot.image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 124, height: 178)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                Button(action: { 
                                    deleteImageAction(id: screenshot.id)
                                }) {
                                    
                                    ZStack {
                                        
                                        Circle()
                                            .fill(Colors.onSecondary.color)
                                        
                                        Icons.deleteIcon.image
                                            .resizable()
                                            .foregroundColor(Colors.secondaryBlue.color)
                                        
                                    } //: ZStack
                                    .frame(width: 26, height: 26)
                                    .offset(x: 8, y: -8)
                                    
                                } //: Button
                                
                            } //: ZStack
                            .frame(width: 124, height: 184)
                            
                        } //: ForEach
                        
                    } //: HStack
                    .padding(.top, 8)
                    .padding(.horizontal, 14)
                    
                } //: ScrollView
                .cardStyle(
                    title: title(
                        isValid: viewModel.isValidScreenshots,
                        inputName: "Screenshot",
                        prefix: "Upload At least 1 "
                    ),
                    titleColor: onBackground(isValid: viewModel.isValidScreenshots),
                    contentPadding: false,
                    background: background(isValid: viewModel.isValidScreenshots)
                )
                
            } //: VStack
            .padding(.top, 21)
            .padding(.horizontal, 12)
            .padding(.bottom, 184)
                        
        } //: ScrollView
    }
    
    var bottomBar: some View {
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
                
                Text("Send Via Mail")
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
            .padding(.bottom, 8)
            
        } //: VStack
        .padding(.bottom, dimensions.insets.bottom)
        .padding(.top, 8)
        .padding(.horizontal, 18)
        .background(Colors.background.color)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            // MARK: INPUTS
            inputs
            
            // MARK: ACTION
            if !keyboardRepository.isShown {
                
                bottomBar
                
            } else {
                
                KeyboardToolbarView(doneAction: doneAction)
                
            } //: if-else
            
        } //: ZStack
        .fillMaxSize()
        .imagePicker(
            isPresented: $viewModel.isImagePickerShown,
            onCompletion: imageSelectedAction
        )
        .sheet(isPresented: $viewModel.isShowingMailView) {
            MailView(
                subject: viewModel.inputTitle,
                message: viewModel.inputDescription,
                recipient: viewModel.inputRecipient,
                screenshots: viewModel.inputScreenshots,
                onSent: sentAction,
                onError: {}
            )
        }
    }
    
    // MARK: - Actions
    func doneAction() {
        keyboardRepository.dismissKeyboard()
    }
    
    func sendAction() {
        withAnimation(.easeInOut(duration: 0.85)) {
            hasTappedSend = true
            viewModel.didTapSend()
        }
    }
    
    func uploadImageAction() {
        withAnimation {
            viewModel.didTapAddImage()
        }
    }
    
    func imageSelectedAction(image: UIImage?) {
        DispatchQueue.main.async {
            viewModel.didSelectImage(image)
        }
    }
    
    func deleteImageAction(id: String) {
        withAnimation {
            viewModel.didTapDeleteImage(id: id)
        }
    }
    
    func sentAction() {
        withAnimation {
            appViewModel.navigateToSettingsRoot()
        }
    }
}

// MARK: - Preview
struct ReportABugView_Previews: PreviewProvider {
    static var viewModel: ReportABugViewModel = {
        let viewModel = ReportABugViewModel(inputTitle: "Bug")
        viewModel.inputDescription = "When I was..."
        viewModel.inputScreenshots = [
            .init(image: .testImage),
            .init(image: .testImage),
            .init(image: .testImage)
        ]
        return viewModel
    }()
    
    static var previews: some View {
        Group {
            
            ReportABugView(viewModel: viewModel)
                .previewDisplayName("Filled In")
            
            ReportABugView(viewModel: .init(inputTitle: "Bug"))
                .previewDisplayName("Empty")
        }
        .previewLayout(.sizeThatFits)
        .background(Colors.background.color)
        .environmentObject(TestData.createAppViewModel())
    }
}
