//
//  NetworkDataRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation
import Combine
import OSLog

// MARK: - Protocol
protocol NetworkDataRepositoryProtocol {
    var totalUsedData: Double { get set }
    var totalUsedDataPublisher: Published<Double>.Publisher { get }
    
    var usedDataInfo: UsedDataInfo { get set }
    var usedDataInfoPublisher: Published<UsedDataInfo>.Publisher { get }
    
    func getTotalUsedData() -> UsedDataInfo
    func receiveDataInfo() -> Void
    func receiveTotalUsedData() -> Void
}

// MARK: - Implementation
// Source: https://stackoverflow.com/questions/25888272/track-cellular-data-usage-using-swift
final class NetworkDataRepository:
    ObservableObject, CustomStringConvertible,
    NetworkDataRepositoryProtocol {
    
    @Published var totalUsedData = 0.0
    var totalUsedDataPublisher: Published<Double>.Publisher { $totalUsedData }
    
    @Published var usedDataInfo: UsedDataInfo = .init()
    var usedDataInfoPublisher: Published<UsedDataInfo>.Publisher { $usedDataInfo }
        
    private var timer: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = .init()

    init(automaticUpdates: Bool = true) {
        if automaticUpdates {
            receiveUpdatedDataInfo()
        }
        receiveTotalUsedData()
    }
    
    func receiveDataInfo() {
        usedDataInfo = getTotalUsedData()
    }
    
    /// receive Data Usage Info every n seconds
    func receiveUpdatedDataInfo(every n: TimeInterval = 2) {
        timer = Timer
            .publish(every: n, on: .main, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.receiveDataInfo()
            }
    }
    
    /// receive total amount of used Data every 2 seconds
    /// Data is retrieved from Data Info which is updated by a Timer
    func receiveTotalUsedData() {
        $usedDataInfo
            .map {
                #if targetEnvironment(simulator)
                    $0.wifiReceived + $0.wifiSent
                #else
                    $0.wirelessWanDataReceived + $0.wirelessWanDataSent
                #endif
            }
            .map { $0.toInt64().toMB() }
            .sink { [weak self] in
                self?.totalUsedData = $0
                Logger.networkRepository.debug("totalUsedData: \($0) MB")
            }
            .store(in: &cancellables)
    }
    
    private enum Interface: String {
        case wwanInterfacePrefix = "pdp_ip"
        case wifiInterfacePrefix = "en"
    }
    
    func getTotalUsedData() -> UsedDataInfo {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        var dataUsageInfo = UsedDataInfo()

        guard getifaddrs(&ifaddr) == 0 else {
            return dataUsageInfo
        }
        
        while let address = ifaddr {
            guard let info = getUsedDataInfo(from: address) else {
                ifaddr = address.pointee.ifa_next
                continue
            }
            dataUsageInfo.updateInfoByAdding(info)
            ifaddr = address.pointee.ifa_next
        }

        freeifaddrs(ifaddr)

        return dataUsageInfo
    }

    private func getUsedDataInfo(from infoPointer: UnsafeMutablePointer<ifaddrs>) -> UsedDataInfo? {
        let pointer = infoPointer
        let name: String! = String(cString: pointer.pointee.ifa_name)
        let address = pointer.pointee.ifa_addr.pointee
        guard address.sa_family == UInt8(AF_LINK) else {
            return nil
        }
        return usedDataInfo(from: pointer, name: name)
    }

    private func usedDataInfo(from pointer: UnsafeMutablePointer<ifaddrs>, name: String) -> UsedDataInfo {
        var networkData: UnsafeMutablePointer<if_data>?
        var dataUsageInfo = UsedDataInfo()

        if name.hasPrefix(Interface.wifiInterfacePrefix.rawValue) {
            networkData = unsafeBitCast(
                pointer.pointee.ifa_data,
                to: UnsafeMutablePointer<if_data>.self
            )
            if let data = networkData {
                dataUsageInfo.wifiSent += UInt64(data.pointee.ifi_obytes)
                dataUsageInfo.wifiReceived += UInt64(data.pointee.ifi_ibytes)
            }

        } else if name.hasPrefix(Interface.wwanInterfacePrefix.rawValue) {
            networkData = unsafeBitCast(
                pointer.pointee.ifa_data,
                to: UnsafeMutablePointer<if_data>.self
            )
            if let data = networkData {
                dataUsageInfo.wirelessWanDataSent += UInt64(data.pointee.ifi_obytes)
                dataUsageInfo.wirelessWanDataReceived += UInt64(data.pointee.ifi_ibytes)
            }
        }
        return dataUsageInfo
    }
    
    // MARK: - Debug
    var description: String {
          """
            
            
            * * * * * *  Network Data Repository  * * * * * *
            
            - Data
              data received: \(usedDataInfo.wirelessWanDataReceived.toInt64().toMB())
              data sent: \(usedDataInfo.wirelessWanDataSent.toInt64().toMB())
              total used data: \(totalUsedData)
            
            
            """
    }
}

class MockNetworkDataRepository: ObservableObject, NetworkDataRepositoryProtocol {
    
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
