//
//  Mock_Network_Data_Repository.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 25/6/23.
//

import Foundation
import Combine

final class MockNetworkDataRepository: ObservableObject, NetworkDataRepositoryProtocol {
    
    private var cancellables: Set<AnyCancellable> = .init()
    private var timer: AnyCancellable?
    private var incrementValueInBytes: Double = 10_000_000
    
    // MARK: - Data
    @Published var totalUsedData = 0.0
    var totalUsedDataPublisher: Published<Double>.Publisher { $totalUsedData }
        
    @Published var usedDataInfo: UsedDataInfo = .init()
    var usedDataInfoPublisher: Published<UsedDataInfo>.Publisher { $usedDataInfo }

    // MARK: - Initializer
    init(
        totalUsedData: Double = 0.0,
        automaticUpdates: Bool = false
    ) {
        self.totalUsedData = totalUsedData
        if automaticUpdates {
            /// receive data info every 2 seconds
            receiveUpdatedDataInfo()
        } else {
            /// receive data info once
            receiveUsedDataInfo()
        }
        receiveTotalUsedData()
    }
    
    // MARK: - Events
    func receiveUpdatedDataInfo(every n: TimeInterval = 2) {
        timer = Timer
            .publish(every: n, on: .main, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else {
                    return
                }
                self.receiveUsedDataInfo()
            }
    }
    
    func receiveUsedDataInfo() {
        usedDataInfo = getTotalUsedData()
    }
    
    func receiveTotalUsedData() {
        $usedDataInfo
            .map { $0.wirelessWanDataReceived + $0.wirelessWanDataSent }
            .map { $0.toInt64().toMB() }
            .sink { [weak self] in self?.totalUsedData = $0 }
            .store(in: &cancellables)
    }
    
    /// Increase data received by `incrementValue`
    func getTotalUsedData() -> UsedDataInfo {
        let dataReceived = totalUsedData.toBytesFromMegabytes() + incrementValueInBytes
        return .init(
            wirelessWanDataReceived: .init(dataReceived),
            wirelessWanDataSent: 0
        )
    }
}
