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
    @Binding var result: Result<MFMailComposeResult, Error>?

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
        .init(presentation: presentation,  result: $result)
    }
}

extension MailView {
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?

        init(
            presentation: Binding<PresentationMode>,
            result: Binding<Result<MFMailComposeResult, Error>?>
        ) {
            _presentation = presentation
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

}
