//
//  WidgetViewModel_Test_Case.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 4/12/22.
//

import XCTest
@testable import Data_Pill

final class WidgetViewModel_Test_Case: XCTestCase {
    
    var widgetViewModel: WidgetViewModel!
    var appDataRepository: AppDataRepositoryProtocol!
    var dataUsageRepository: DataUsageRepositoryProtocol!
    var networkDataRepository: NetworkDataRepositoryProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
        widgetViewModel = createWidgetViewModel()
    }

    override func tearDownWithError() throws {
        widgetViewModel = nil
    }
    
    func createWidgetViewModel() -> WidgetViewModel {
        appDataRepository = MockAppDataRepository()
        dataUsageRepository = DataUsageRepository(
            database: InMemoryLocalDatabase(container: .dataUsage, appGroup: nil)
        )
        networkDataRepository = MockNetworkDataRepository()
        
        return .init(
            appDataRepository: appDataRepository,
            dataUsageRepository: dataUsageRepository,
            networkDataRepository: networkDataRepository,
            republishAndObserveData: false
        )
    }
    
    func test_get_latest_app_data() throws {
        // (1) Given
        let startDate = "2022-10-01T00:00:00+00:00".toDate()
        let endDate = "2022-10-30T00:00:00+00:00".toDate()
        let unit = Unit.gb
        let dataAmount = 19.0
        let dataLimit = 18.0
        let dataLimitPerDay = 1.0
        let usageType = ToggleItem.daily
        
        // (2) When
        widgetViewModel.republishAndObserveData()
        appDataRepository.loadAllData(
            startDate: startDate,
            endDate: endDate,
            dataAmount: dataAmount,
            dataLimit: dataLimit,
            dataLimitPerDay: dataLimitPerDay,
            unit: unit,
            usageType: usageType
        )
        
        // (3) Then
        XCTAssertEqual(widgetViewModel.startDate, "2022-10-01T00:00:00+00:00".toDate())
        XCTAssertEqual(widgetViewModel.endDate, "2022-10-30T00:00:00+00:00".toDate())
        XCTAssertEqual(widgetViewModel.unit, Unit.gb)
        XCTAssertEqual(widgetViewModel.dataAmount, 19.0)
        XCTAssertEqual(widgetViewModel.dataLimit, 18.0)
        XCTAssertEqual(widgetViewModel.dataLimitPerDay, 1.0)
        XCTAssertEqual(widgetViewModel.usageType, ToggleItem.daily)
    }
    
    func test_get_latest_network_data() throws {
        // (1) Given
        // wirelessWanDataReceived = 10_000_000
        // wirelessWanDataSent = 485_760
        
        // (2) When
        widgetViewModel.republishAndObserveData()
        networkDataRepository.receiveDataInfo()
        
        // (3) Then
        XCTAssertEqual(widgetViewModel.totalUsedData, 10.0)
    }
}
