//
//  ReportABugViewModel.swift
//  Data Pill
//
//  Created by Wind Versi on 1/2/24.
//

import Combine
import OSLog
import MessageUI

final class ReportABugViewModel: ObservableObject {
    
    var subscriptions: Set<AnyCancellable> = .init()
                
    // MARK: - Dependencies
    
    // MARK: - Data
    
    // MARK: - UI
    @Published var inputTitle: String = ""
    @Published var inputDescription: String = ""
    @Published var inputScreenshots: [Screenshot] = []
    let inputRecipient: String = "penguinworksco@gmail.com"
    let inputDescriptionMinChar: Int = 20
    
    @Published var isImagePickerShown: Bool = false
    @Published var isShowingMailView: Bool = false
    @Published var isAlertShown: Bool = false
    @Published var alertMessage: String?
    
    var isValidTitle: Bool {
        !inputTitle.isEmpty
    }
    
    var isValidDescription: Bool {
        !inputDescription.isEmpty && inputDescription.count >= inputDescriptionMinChar
    }
    
    var isValidScreenshots: Bool {
        !inputScreenshots.isEmpty
    }
    
    var areAllValid: Bool {
        isValidTitle &&
        isValidDescription &&
        isValidScreenshots
    }
    
    init(inputTitle: String = "Bug") {
        self.inputTitle = inputTitle
    }
}
