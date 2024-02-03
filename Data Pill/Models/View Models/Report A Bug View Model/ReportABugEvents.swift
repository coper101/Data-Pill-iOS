//
//  ReportABugEvents.swift
//  Data Pill
//
//  Created by Wind Versi on 3/2/24.
//

import OSLog
import PhotosUI
import MessageUI

// MARK: - Send
extension ReportABugViewModel {
    
    func didTapSend() {
        guard areAllValid else {
            return
        }
        isShowingMailView = true
    }
}

// MARK: - Image
extension ReportABugViewModel {
    
    func didTapAddImage() {
        Task {
            await showImagePicker()
        }
    }
    
    func didTapDeleteImage(id: String) {
        inputScreenshots.removeAll(where: { $0.id == id })
    }
    
    func didSelectImage(_ image: UIImage?) {
        guard let image else {
            return
        }
        inputScreenshots.append(.init(image: image))
    }
    
    func showImagePicker() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .notDetermined:
            Logger.reportABug.debug("📷 Photo Access Auth Status: Not Dermined | Requesting...")
            await requestPhotoAccess()
        case .restricted:
            Logger.reportABug.debug("📷 Photo Access Auth Status: Restricted")
            await showAlert(message: "Please allow access to photos in Settings to upload a photo")
        case .denied:
            Logger.reportABug.debug("📷 Photo Access Auth Status: Denied")
            await showAlert(message: "Please allow access to photos in Settings to upload a photo")
        case .authorized:
            Logger.reportABug.debug("📷 Photo Access Auth Status: Authorized | Showing Image Picker...")
            await presentImagePicker()
        case .limited:
            Logger.reportABug.debug("📷 Photo Access Auth Status: Limited")
            await showAlert(message: "Please allow access to \"All Photos\" in settings to upload a photo")
        @unknown default:
            Logger.reportABug.debug("📷 Photo Access Auth Status: Unknown")
        }
    }
    
    func requestPhotoAccess() async {
        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await showImagePicker()
    }
    
    @MainActor
    func presentImagePicker(isLimited: Bool = false) async {
        isImagePickerShown = true
    }
}

// MARK: Alert
extension ReportABugViewModel {
    
    @MainActor
    func showAlert(message: String) {
        alertMessage = message
        isAlertShown = true
    }
    
    @MainActor
    func closeAlert() {
        isAlertShown = false
        alertMessage = nil
    }
}
