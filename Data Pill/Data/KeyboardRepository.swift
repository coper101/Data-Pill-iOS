//
//  KeyboardRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 4/2/24.
//

import SwiftUI
import Combine

final class KeyboardRepository: ObservableObject {
    
    private var subscriptions: Set<AnyCancellable> = .init()

    // MARK: - Data
    @Published var isShown: Bool = false
    
    init() {
        observeKeyboard()
    }
    
    // MARK: - Events
    private func observeKeyboard() {
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] _ in self?.isShown = true }
            .store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in self?.isShown = false }
            .store(in: &subscriptions)
    }
}

// MARK: - Events
extension KeyboardRepository {
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
