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
    var hasInternetConnection: Bool { get set }
    var hasInternetConnectionPublisher: Published<Bool>.Publisher { get }
}



// MARK: - App Implementation
final class NetworkConnectionRepository: ObservableObject, NetworkConnectivity {
    
    var cancellables: Set<AnyCancellable> = .init()
    
    @Published var wifiStatus: NWPath.Status? = nil
    @Published var celullarStatus: NWPath.Status? = nil
    
    @Published var hasInternetConnection: Bool = true
    var hasInternetConnectionPublisher: Published<Bool>.Publisher { $hasInternetConnection }
    
    private let monitorWifi = NWPathMonitor(requiredInterfaceType: .wifi)
    private let monitorCellular = NWPathMonitor(requiredInterfaceType: .cellular)
    
    init() {
        startMonitoring()
        observeInternetConnection()
    }
    
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
