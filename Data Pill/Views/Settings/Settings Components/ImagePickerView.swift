//
//  ImagePickerView.swift
//  Data Pill
//
//  Created by Wind Versi on 1/2/24.
//

import PhotosUI
import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    // MARK: - Props
    var onCompletion: (UIImage?) -> Void

    // MARK: - UI
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        .init(self)
    }
}

extension ImagePickerView {
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else {
                return
            }

            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.onCompletion(image as? UIImage)
                    }
                }
            }
        }
    }
}

struct ImagePickerModifier: ViewModifier {
    // MARK: - Props
    @Binding var isPresented: Bool
    var onCompletion: (UIImage?) -> Void
    
    // MARK: - UI
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                ImagePickerView(onCompletion: onCompletion)
            }
    }
}

extension View {
    
    func imagePicker(isPresented: Binding<Bool>, onCompletion: @escaping (UIImage?) -> Void) -> some View {
        modifier(
            ImagePickerModifier(
                isPresented: isPresented,
                onCompletion: onCompletion
            )
        )
    }
}
