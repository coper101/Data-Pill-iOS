//
//  Mock_Network_Connection_Repository.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 1/7/23.
//

@testable import Data_Pill
import Foundation
import Combine

final class MockNoNetworkConnectionRepository: NetworkConnectivity {
    
    @Published var hasInternetConnection: Bool = false
    var hasInternetConnectionPublisher: Published<Bool>.Publisher { $hasInternetConnection }
    
}

final class MockHasNetworkConnectionRepository: NetworkConnectivity {
    
    @Published var hasInternetConnection: Bool = true
    var hasInternetConnectionPublisher: Published<Bool>.Publisher { $hasInternetConnection }
    
}

