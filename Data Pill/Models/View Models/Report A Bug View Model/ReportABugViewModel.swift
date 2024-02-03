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
    @Published var inputEmailAddress: String = ""
    @Published var inputTitle: String = ""
    @Published var inputDescription: String = ""
    @Published var inputScreenshots: [Screenshot] = []
    let inputRecipient: String = "penguinworksco@gmail.com"
    
    @Published var isImagePickerShown: Bool = false
    @Published var isShowingMailView: Bool = false
    @Published var mailResult: Result<MFMailComposeResult, Error>? 
    @Published var isAlertShown: Bool = false
    @Published var alertMessage: String?
    
    var isValidEmailAddress: Bool {
        Validator.isValidEmailAddress(inputEmailAddress)
    }
    
    var isValidTitle: Bool {
        !inputTitle.isEmpty
    }
    
    var isValidDescription: Bool {
        !inputDescription.isEmpty && inputDescription.count >= 10
    }
    
    var isValidScreenshots: Bool {
        !inputScreenshots.isEmpty
    }
    
    var areAllValid: Bool {
        isValidTitle &&
        isValidDescription &&
        isValidEmailAddress &&
        isValidScreenshots
    }
}
