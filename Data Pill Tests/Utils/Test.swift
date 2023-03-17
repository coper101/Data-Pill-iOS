//
//  Test.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 13/3/23.
//

import Combine
import XCTest
@testable import Data_Pill

extension XCTestCase {
    
    /**
     Returns a New App View Model with an options to provide default Dependencies
     - Parameters:
        - setupValues: Triggers the inflow of data from all Data Sources
     */
    func createAppViewModel(
        appDataRepository: AppDataRepositoryProtocol? = nil,
        dataUsageRepository: DataUsageRepositoryProtocol? = nil,
        dataUsageRemoteRepository: DataUsageRemoteRepositoryProtocol? = nil,
        networkDataRepository: NetworkDataRepositoryProtocol? = nil,
        setupValues: Bool = false,
        withTotalUsedData totalUsedData: Double = 0
    ) -> AppViewModel {
        let defaultDataUsageRepository = DataUsageRepository(
            database: InMemoryLocalDatabase(container: .dataUsage, appGroup: nil)
        )
        defaultDataUsageRepository.addData(
            date: Calendar.current.startOfDay(for: .init()),
            totalUsedData: totalUsedData,
            dailyUsedData: 0,
            hasLastTotal: true
        )
        let defaultDataUsageRemoteRepository = DataUsageRemoteRepository(
            remoteDatabase: MockSuccessCloudDatabase()
        )
        
        return .init(
            appDataRepository: appDataRepository ?? MockAppDataRepository(),
            dataUsageRepository: dataUsageRepository ?? defaultDataUsageRepository,
            dataUsageRemoteRepository: dataUsageRemoteRepository ?? defaultDataUsageRemoteRepository,
            networkDataRepository: networkDataRepository ?? MockNetworkDataRepository(),
            setupValues: setupValues
        )
    }
    
    func createExpectation<Output, E>(
        publisher: AnyPublisher<Output, E>,
        description: String,
        timeout: TimeInterval = 0.5,
        onFailure: @escaping (Error) -> Void = { _ in },
        onSuccess: @escaping (Output) -> Void
    ) {
        let expectation = expectation(description: description)
        var subscriptions = Set<AnyCancellable>()
        
        publisher.sink { completion in
            switch completion {
            case .failure(let error):
                onFailure(error)
                break
            case .finished:
                // called when received value
                break;
            }
            
            expectation.fulfill()
        } receiveValue: { output in
            onSuccess(output)
        }
        .store(in: &subscriptions)

        waitForExpectations(timeout: timeout)
    }
}
