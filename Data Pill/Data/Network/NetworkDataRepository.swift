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
    
    // MARK: - Data
    /// - Store
    var totalUsedData: Double { get set }
    var totalUsedDataPublisher: Published<Double>.Publisher { get }
    
    var usedDataInfo: UsedDataInfo { get set }
    var usedDataInfoPublisher: Published<UsedDataInfo>.Publisher { get }
    
    /// - Events
    func getTotalUsedData() -> UsedDataInfo
    func receiveUsedDataInfo() -> Void
    func receiveTotalUsedData() -> Void
}



// MARK: - App Implementation
/// Source: https://stackoverflow.com/questions/25888272/track-cellular-data-usage-using-swift
final class NetworkDataRepository: ObservableObject, CustomStringConvertible, NetworkDataRepositoryProtocol {
    
    private var cancellables: Set<AnyCancellable> = .init()
    private var timer: AnyCancellable?

    
    // MARK: - Data
    @Published var totalUsedData = 0.0
    var totalUsedDataPublisher: Published<Double>.Publisher { $totalUsedData }
    
    @Published var usedDataInfo: UsedDataInfo = .init()
    var usedDataInfoPublisher: Published<UsedDataInfo>.Publisher { $usedDataInfo }
        

    // MARK: - Initializer
    /// - Parameter automaticUpdates: Whether to receive data usage update every time interval specified.
    init(automaticUpdates: Bool = true) {
        if automaticUpdates {
            receiveUpdatedDataInfo()
        }
        receiveTotalUsedData()
    }
    
    
    // MARK: - Events
    /// Receives ``UsedDataInfo`` every `n` seconds specified by calling ``receiveUsedDataInfo()``.
    ///
    /// - Parameter every: The number of seconds to receive data usage update. Default is 2 seconds.
    ///
    func receiveUpdatedDataInfo(every n: TimeInterval = 2) {
        timer = Timer
            .publish(every: n, on: .main, in: .default)
            .autoconnect()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.receiveUsedDataInfo()
            }
    }
    
    /// Set the `usedDataInfo` store.
    func receiveUsedDataInfo() {
        usedDataInfo = getTotalUsedData()
    }
    
    /// Receives the `usedDataInfo` on change and calculates the amount of total used data
    /// and sets the `totalUsedData` store.
    func receiveTotalUsedData() {
        $usedDataInfo
            .map {
                // #if targetEnvironment(simulator)
                //     $0.wifiReceived + $0.wifiSent
                // #else
                    $0.wirelessWanDataReceived + $0.wirelessWanDataSent
                // #endif
            }
            .map { $0.toInt64().toMB() }
            .sink { [weak self] in
                self?.totalUsedData = $0
                Logger.networkRepository.debug("- NETWORK DATA: 📶 Total Used Data is \($0) MB")
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
