//
//  NetworkDataRepository.swift
//  Data Pill
//
//  Created by Wind Versi on 2/10/22.
//

import Foundation
import Combine

// Source: https://stackoverflow.com/questions/25888272/track-cellular-data-usage-using-swift

struct UsedDataInfo {
    var wifiReceived: UInt64 = 0
    var wifiSent: UInt64 = 0
    var wirelessWanDataReceived: UInt64 = 0
    var wirelessWanDataSent: UInt64 = 0

    mutating func updateInfoByAdding(_ info: Self) {
        wifiSent += info.wifiSent
        wifiReceived += info.wifiReceived
        wirelessWanDataSent += info.wirelessWanDataSent
        wirelessWanDataReceived += info.wirelessWanDataReceived
    }
    
}

class NetworkDataRepository: ObservableObject, CustomStringConvertible {
    
    // MARK: - Data
    @Published var usedDataInfo: UsedDataInfo = .init()
    @Published var totalUsedData = 0.0
    var cancellables: Set<AnyCancellable> = .init()

    // MARK: - Initializer
    init() {
        loadTotalUsedData()
    }
    
    // MARK: - Functions
    func loadTotalUsedData() {
        usedDataInfo = getTotalUsedData()
        
        $usedDataInfo
            .map { $0.wirelessWanDataReceived + $0.wirelessWanDataSent }
            .map { $0.toInt64().toMB() }
            .sink { [weak self] in
                self?.totalUsedData = $0 // in MB
            }
            .store(in: &cancellables)
    }
    
    private enum Interface: String {
        case wwanInterfacePrefix = "pdp_ip"
        case wifiInterfacePrefix = "en"
    }
    
    private func getTotalUsedData() -> UsedDataInfo {
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

    private func getUsedDataInfo(
        from infoPointer: UnsafeMutablePointer<ifaddrs>
    ) -> UsedDataInfo? {
    let pointer = infoPointer
    let name: String! = String(cString: pointer.pointee.ifa_name)
    let address = pointer.pointee.ifa_addr.pointee
    guard address.sa_family == UInt8(AF_LINK) else {
        return nil
    }
    return usedDataInfo(from: pointer, name: name)
}

    private func usedDataInfo(
        from pointer: UnsafeMutablePointer<ifaddrs>,
        name: String
    ) -> UsedDataInfo {
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
            
            * NetworkDataRepository *
            
            - Data
              dataReceived: \(usedDataInfo.wirelessWanDataReceived.toInt64().toMB())
              dataSent: \(usedDataInfo.wirelessWanDataSent.toInt64().toMB())
            
            """
    }
}

