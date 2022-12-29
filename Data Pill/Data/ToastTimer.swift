//
//  ToastTimer.swift
//  Data Pill
//
//  Created by Wind Versi on 28/12/22.
//

import Combine
import Foundation

final class ToastTimer: ObservableObject {
    
    @Published var timer: AnyCancellable?
    @Published var message: String?
    
    func showToast(message: String) {
        if timer != nil {
            stopTimer()
        }
        self.message = message
        scheduleToCancelToast(message)
    }
    
    func scheduleToCancelToast(_ message: String) {
        self.timer = Timer
            .publish(every: 3, on: .main, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reset()
            }
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    func reset() {
        stopTimer()
        self.message = nil
    }
    
}
