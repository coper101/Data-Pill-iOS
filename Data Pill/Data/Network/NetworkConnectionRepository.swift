//
//  NetworkConnectionRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 21/2/23.
//

import Combine
import Network

// MARK: - Protocol
protocol NetworkConnectivity {
    
    // MARK: - Data
    /// - Store
    var hasInternetConnection: Bool { get set }
    var hasInternetConnectionPublisher: Published<Bool>.Publisher { get }
}



// MARK: - App Implementation
final class NetworkConnectionRepository: ObservableObject, NetworkConnectivity {
    
    var cancellables: Set<AnyCancellable> = .init()
    
    
    // MARK: - Data
    @Published var networkStatus: NWPath.Status? = nil
    
    @Published var hasInternetConnection: Bool = true
    var hasInternetConnectionPublisher: Published<Bool>.Publisher { $hasInternetConnection }
    
    private let monitorNetwork = NWPathMonitor()
    
    // MARK: - Initializer
    init() {
        startMonitoring()
    }
    
    // MARK: - Events
    func startMonitoring() {
        monitorNetwork.pathUpdateHandler = {
            self.hasInternetConnection = $0.status == .satisfied
        }
        monitorNetwork.start(queue: .main)
    }
}
