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
    @Published var wifiStatus: NWPath.Status? = nil
    @Published var celullarStatus: NWPath.Status? = nil
    
    @Published var hasInternetConnection: Bool = true
    var hasInternetConnectionPublisher: Published<Bool>.Publisher { $hasInternetConnection }
    
    private let monitorWifi = NWPathMonitor(requiredInterfaceType: .wifi)
    private let monitorCellular = NWPathMonitor(requiredInterfaceType: .cellular)
    
    
    // MARK: - Initializer
    init() {
        startMonitoring()
        observeInternetConnection()
    }
    
    
    // MARK: - Events
    /// Start observing the status of Mobile Data and Wifi.
    func startMonitoring() {
        monitorWifi.pathUpdateHandler = {
            self.wifiStatus = $0.status
        }
        monitorCellular.pathUpdateHandler = {
            self.celullarStatus = $0.status
        }
        monitorWifi.start(queue: .main)
        monitorCellular.start(queue: .main)
    }
    
    
    // MARK: - Observers
    /// Observe whether internet connection is available or not by deriving it from the `wifiStatus` and `cellularStatus`
    /// and sets the `hasInternet` store.
    func observeInternetConnection() {
        $wifiStatus
            .combineLatest($celullarStatus)
            .sink { [weak self] (wifiStatus, celullarStatus) in
                let hasInternet = (wifiStatus == .satisfied) || (celullarStatus == .satisfied)
                self?.hasInternetConnection = hasInternet
            }
            .store(in: &cancellables)
    }
}
