//
//  NetworkDataRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation
import Combine

// MARK: - Protocol
protocol NetworkDataRepositoryProtocol {
    var totalUsedData: Double { get set }
    var totalUsedDataPublisher: Published<Double>.Publisher { get }
}

// MARK: - Implementations
// Source: https://stackoverflow.com/questions/25888272/track-cellular-data-usage-using-swift
class NetworkDataRepository: ObservableObject, CustomStringConvertible, NetworkDataRepositoryProtocol {
    
    // MARK: - Data
    @Published var usedDataInfo: UsedDataInfo = .init()
    
    @Published var totalUsedData = 0.0
    var totalUsedDataPublisher: Published<Double>.Publisher { $totalUsedData }
        
    private var timer: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = .init()

    // MARK: - Initializer
    init() {
        receiveUpdatedDataInfo()
        receiveTotalUsedData()
    }
    
    // MARK: - Functions
    
    /// receive Data Usage Info every 2 seconds
    func receiveUpdatedDataInfo() {
        timer = Timer
            .publish(every: 2, on: .main, in: .default)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.usedDataInfo = self.getTotalUsedData()
            }
    }
    
    /// receive total amount of used Data every 2 seconds
    /// Data is retrieved from Data Info which is updated by a Timer
    func receiveTotalUsedData() {
        $usedDataInfo
            .map { $0.wirelessWanDataReceived + $0.wirelessWanDataSent }
            .map { $0.toInt64().toMB() }
            .sink { [weak self] in
                self?.totalUsedData = $0
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
            
            
            * * Network Data Repository * *
            
            - Data
              data received: \(usedDataInfo.wirelessWanDataReceived.toInt64().toMB())
              data sent: \(usedDataInfo.wirelessWanDataSent.toInt64().toMB())
              total used data: \(totalUsedData)
            
            
            """
    }
}

class NetworkDataFakeRepository: ObservableObject, NetworkDataRepositoryProtocol {
    
    // MARK: - Data
    @Published var totalUsedData = 0.0
    var totalUsedDataPublisher: Published<Double>.Publisher { $totalUsedData }
        
    init(totalUsedData: Double) {
        self.totalUsedData = totalUsedData
    }
}
