//
//  Widget_Model_Tests.swift
//  Data Pill Tests
//
//  Created by Wind Versi on 4/12/22.
//

import XCTest
@testable import Data_Pill

final class Widget_Model_Tests: XCTestCase {
    
    private var widgetModel: WidgetModel!
    private var appDataRepository: AppDataRepositoryProtocol!
    private var dataUsageRepository: DataUsageRepositoryProtocol!
    private var networkDataRepository: NetworkDataRepositoryProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
        widgetModel = createWidgetModel()
    }

    override func tearDownWithError() throws {
        widgetModel = nil
    }
    
    func createWidgetModel() -> WidgetModel {
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
        let unit = Unit.gb
        let usageType = ToggleItem.daily
        
        // (2) When
        widgetModel.republishAndObserveData()
        appDataRepository.loadAllData(
            unit: unit,
            usageType: usageType
        )
        
        // (3) Then
        XCTAssertEqual(widgetModel.unit, Unit.gb)
        XCTAssertEqual(widgetModel.usageType, ToggleItem.daily)
    }
    
    func test_get_latest_network_data() throws {
        // (1) Given
        // wirelessWanDataReceived = 10_000_000
        // wirelessWanDataSent = 485_760
        
        // (2) When
        widgetModel.republishAndObserveData()
        networkDataRepository.receiveDataInfo()
        
        // (3) Then
        XCTAssertEqual(widgetModel.totalUsedData, 10.0)
    }
}
