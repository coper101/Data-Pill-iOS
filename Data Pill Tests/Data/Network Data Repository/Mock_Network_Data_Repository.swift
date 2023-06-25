//
//  Mock_Network_Data_Repository.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 25/6/23.
//

@testable import Data_Pill
import Foundation
import Combine

final class MockNetworkDataRepository: ObservableObject, NetworkDataRepositoryProtocol {
    
    @Published var totalUsedData = 0.0
    var totalUsedDataPublisher: Published<Double>.Publisher { $totalUsedData }
        
    @Published var usedDataInfo: UsedDataInfo = .init()
    var usedDataInfoPublisher: Published<UsedDataInfo>.Publisher { $usedDataInfo }

    private var cancellables: Set<AnyCancellable> = .init()

    init(totalUsedData: Double = 0.0) {
        self.totalUsedData = totalUsedData
        receiveTotalUsedData()
    }
    
    func receiveDataInfo() {
        usedDataInfo = getTotalUsedData()
    }
    
    func receiveTotalUsedData() {
        $usedDataInfo
            .map { $0.wirelessWanDataReceived + $0.wirelessWanDataSent }
            .map { $0.toInt64().toMB() }
            .sink { [weak self] in
                self?.totalUsedData = $0
            }
            .store(in: &cancellables)
    }
    
    func getTotalUsedData() -> UsedDataInfo {
        .init(
            wirelessWanDataReceived: 10_000_000 ,
            wirelessWanDataSent: 485_760
        )
    }
}
