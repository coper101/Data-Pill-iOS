//
//  ShareSheetView.swift
//  Data Pill
//
//  Created by Wind Versi on 3/2/24.
//

import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {
    // MARK: - Props
    @Environment(\.presentationMode) var presentation
    let subject: String
    let message: String
    let recipient: String
    let screenshots: [Screenshot]
    let onSent: () -> Void
    let onError: () -> Void

    // MARK: - UI
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients([recipient])
        vc.setSubject(subject)
        vc.setMessageBody(message, isHTML: false)
        screenshots.enumerated().forEach { (index, screenshot) in
            if let data = screenshot.image.pngData() {
                vc.addAttachmentData(
                    data,
                    mimeType: "image/png",
                    fileName: "\(index + 1)"
                )
            }
        }
        return vc
    }

    func updateUIViewController(
        _ uiViewController: MFMailComposeViewController,
        context: UIViewControllerRepresentableContext<MailView>
    ) {

    }
    
    func makeCoordinator() -> Coordinator {
        .init(presentation: presentation, onSent: onSent, onError: onError)
    }
}

extension MailView {
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var presentation: PresentationMode
        let onSent: () -> Void
        let onError: () -> Void

        init(
            presentation: Binding<PresentationMode>,
            onSent: @escaping () -> Void,
            onError: @escaping () -> Void
        ) {
            _presentation = presentation
            self.onSent = onSent
            self.onError = onError
        }
        
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                onError()
                return
            }
            switch result {
            case .cancelled:
                break
            case .saved:
                break
            case .sent:
                onSent()
            case .failed:
                break
            default:
                break
            }
        }
                
    } //: class
}
