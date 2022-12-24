//
//  Data_Pill_UI_Tests.swift
//  Data Pill UI Tests
//
//  Created by Wind Versi on 24/12/22.
//

import XCTest

final class Data_Pill_UI_Tests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func test_main_screen() throws {
        // MARK: Daily Limit Info
//        let dailyLimitCard = app
//            .otherElements
//            .containing(.init(format: "identifier == 'dailyLimit'"))
//        XCTAssertGreaterThan(planLimitCard.count, 0)
//
//        XCTAssert(
//            dailyLimitCard
//                .staticTexts
//                .containing(.init(format: "label BEGINSWITH 'Daily'"))
//                .containing(.init(format: "label ENDSWITH 'Limit'"))
//                .element
//                .exists
//        )
//        XCTAssert(dailyLimitCard.staticTexts["limitAmount"].exists)
//        XCTAssert(dailyLimitCard.staticTexts["limitUnit"].exists)
//        XCTAssert(dailyLimitCard.buttons["Right Arrow Icon"].exists)
    }
    
    // MARK: - Pill
    func test_pill() throws {
        let pillButton = getElement(type: .button, identifier: "pill", label: "TODAY")
        XCTAssert(pillButton.exists)
        
        try open_history(pillButton)
        try close_history()
    }
    
    func open_history(_ pillButton: XCUIElement) throws {
        pillButton.tap()

        // MARK: Top Bar
        let weekLabel = getElement(type: .text, identifier: "history", label: "This Week")
        let closeButton = getElement(type: .button, identifier: "history", label: "X Mark Icon")
        XCTAssert(weekLabel.exists)
        XCTAssert(closeButton.exists)
        
        // MARK: Day Pills
        let dayPercentageLabel = getElement(type: .text, identifier: "history", label: "0%")
        let dayLabel = getElement(type: .text, identifier: "history", label: "TODAY")
        XCTAssert(dayPercentageLabel.exists)
        XCTAssert(dayLabel.exists)
    }
    
    func close_history() throws {
        let closeButton = getElement(type: .button, identifier: "history", label: "X Mark Icon")
        closeButton.tap()
        
        XCTAssertFalse(hasElements(identifier: "history"))
    }
    
    // MARK: - Used Card
    func test_used() throws {
        let usedLabel = getElement(type: .text, identifier: "used", label: "USED")
        let percentageNumberLabel = getElement(type: .text, identifier: "used", label: "percentageUsedNumber")
        let percentageSignLabel = getElement(type: .text, identifier: "used", label: "percentageUsedSign")
        let dataAmountLabel = getElement(type: .text, identifier: "used", label: "dataUsedAmount")
        XCTAssert(usedLabel.exists)
        XCTAssert(percentageNumberLabel.exists)
        XCTAssert(percentageSignLabel.exists)
        XCTAssert(dataAmountLabel.exists)
    }
    
    // MARK: - Usage Card
    func test_usage() throws {
        let usageLabel = getElement(type: .text, identifier: "usage", label: "USAGE")
        let planToggleButton = getElement(type: .button, identifier: "usage", label: "Plan")
        let dailyToggleButton = getElement(type: .button, identifier: "usage", label: "Daily")
        XCTAssert(usageLabel.exists)
        XCTAssert(planToggleButton.exists)
        XCTAssert(dailyToggleButton.exists)
        
        try toggle_usage_type(planToggleButton, dailyToggleButton)
    }
    
    func toggle_usage_type(_ planButton: XCUIElement, _ dailyButton: XCUIElement) throws {
        planButton.tap()
        dailyButton.tap()
    }
    
    // MARK: - Period Card
    func test_period() throws {
        let periodCardLabel = getElement(type: .text, identifier: "period", label: "PERIOD")
        let manualOptionButton = getElement(type: .button, identifier: "period", label: "Manual")
        XCTAssert(periodCardLabel.exists)
        XCTAssert(manualOptionButton.exists)
        
        try toggle_auto_period()
    }
    
    func toggle_auto_period() throws {
        let manualOptionButton = getElement(type: .button, identifier: "period", label: "Manual")
        let autoOptionButton = getElement(type: .button, identifier: "period", label: "Auto")
        manualOptionButton.tap()
        XCTAssert(autoOptionButton.exists)
        autoOptionButton.tap()
        XCTAssert(manualOptionButton.exists)
    }
    
    // MARK: - Data Plan Card
    func test_data_plan() throws {
        let dataPlanLabel = getElement(type: .text, identifier: "dataPlan", label: "Data Plan")
        XCTAssert(dataPlanLabel.exists)
                
        let periodButton = getElement(type: .button, identifier: "dataPlan", label: "period")
        let periodButtonImage = periodButton.images["Right Arrow Icon"]
        XCTAssert(periodButton.exists)
        XCTAssert(periodButtonImage.exists)

        let amountButton = getElement(type: .button, identifier: "dataPlan", label: "amount")
        let amountButtonImage = amountButton.images["Right Arrow Icon"]
        XCTAssert(amountButton.exists)
        XCTAssert(amountButtonImage.exists)

        try open_then_close_edit_period(periodButton)
        try open_then_close_edit_data_amount(amountButton)
    }
    
    func open_then_close_edit_period(_ periodButton: XCUIElement) throws {
        periodButton.tap()
        
        let saveButton = app.buttons["Save"]
        let periodLabel = getElement(type: .text, identifier: "dataPlan", label: "Period")

        XCTAssert(saveButton.waitForExistence(timeout: 0.5))
        XCTAssert(periodLabel.exists)
        
        saveButton.tap()
        
        XCTAssertFalse(saveButton.waitForExistence(timeout: 0.5))
        XCTAssertFalse(periodLabel.exists)
    }
    
    func open_then_close_edit_data_amount(_ amountButton: XCUIElement) throws {
        amountButton.tap()
        
        let saveButton = app.buttons["Save"]
        let dataAmountLabel = getElement(type: .text, identifier: "dataPlan", label: "Data Amount")
        let plusButton = getElement(type: .button, identifier: "dataPlan", label: "Plus")
        let minusButton = getElement(type: .button, identifier: "dataPlan", label: "Minus")

        XCTAssert(saveButton.waitForExistence(timeout: 0.5))
        XCTAssert(dataAmountLabel.exists)
        XCTAssert(plusButton.exists)
        XCTAssert(minusButton.exists)
        
        saveButton.tap()
        
        XCTAssertFalse(saveButton.waitForExistence(timeout: 0.5))
        XCTAssertFalse(dataAmountLabel.exists)
        XCTAssertFalse(plusButton.exists)
        XCTAssertFalse(minusButton.exists)
    }
    
    // MARK: - Plan Limit
    func test_plan_limit() throws {
        let planLimitLabel = app.staticTexts
            .matching(.init(format: "identifier == [cd] %@", "planLimit"))
            .containing(.init(format: "label BEGINSWITH 'Plan'"))
            .containing(.init(format: "label ENDSWITH 'Limit'"))
            .element
        XCTAssert(planLimitLabel.exists)
        
        let limitAmount = getElement(type: .text, identifier: "planLimit", label: "limitAmount")
        let limitUnit = getElement(type: .text, identifier: "planLimit", label: "limitUnit")
        let editButton = getElement(type: .button, identifier: "planLimit", label: "Right Arrow Icon")

        XCTAssert(limitAmount.exists)
        XCTAssert(limitUnit.exists)
        XCTAssert(editButton.exists)
        
        try open_the_close_edit_plan_limit(editButton)
    }
    
    func open_the_close_edit_plan_limit(_ editButton: XCUIElement) throws {
        if !editButton.isVisible() {
            app.swipeUp()
        }
        editButton.tap()
        
        let saveButton = app.buttons["Save"]
        let planLimitLabel = getElement(type: .text, identifier: "planLimit", label: "Plan Limit")
        let plusButton = getElement(type: .button, identifier: "planLimit", label: "Plus")
        let minusButton = getElement(type: .button, identifier: "planLimit", label: "Minus")

        XCTAssert(saveButton.waitForExistence(timeout: 0.5))
        XCTAssert(planLimitLabel.exists)
        XCTAssert(plusButton.exists)
        XCTAssert(minusButton.exists)
        
        saveButton.tap()
        
        XCTAssertFalse(saveButton.waitForExistence(timeout: 0.5))
        XCTAssertFalse(plusButton.exists)
        XCTAssertFalse(minusButton.exists)
    }
    
    // MARK: - Daily Limit
    func test_daily_limit() throws {
        let dailyLimitLabel = app.staticTexts
            .matching(.init(format: "identifier == [cd] %@", "dailyLimit"))
            .containing(.init(format: "label BEGINSWITH 'Daily'"))
            .containing(.init(format: "label ENDSWITH 'Limit'"))
            .element
        XCTAssert(dailyLimitLabel.exists)
        
        let limitAmount = getElement(type: .text, identifier: "dailyLimit", label: "limitAmount")
        let limitUnit = getElement(type: .text, identifier: "dailyLimit", label: "limitUnit")
        let editButton = getElement(type: .button, identifier: "dailyLimit", label: "Right Arrow Icon")

        XCTAssert(limitAmount.waitForExistence(timeout: 0.5))
        XCTAssert(limitUnit.exists)
        XCTAssert(editButton.exists)
        
        try open_then_close_edit_daily_limit(editButton)
    }
    
    func open_then_close_edit_daily_limit(_ editButton: XCUIElement) throws {
        if !editButton.isVisible() {
            app.swipeUp()
        }
        editButton.tap()
                        
        let saveButton = app.buttons["Save"]
        let dailyLimitLabel = getElement(type: .text, identifier: "dailyLimit", label: "Daily Limit")
        let plusButton = getElement(type: .button, identifier: "dailyLimit", label: "Plus")
        let minusButton = getElement(type: .button, identifier: "dailyLimit", label: "Minus")

        XCTAssert(saveButton.waitForExistence(timeout: 0.5))
        XCTAssert(dailyLimitLabel.exists)
        XCTAssert(plusButton.exists)
        XCTAssert(minusButton.exists)
        
        saveButton.tap()
        
        XCTAssertFalse(saveButton.waitForExistence(timeout: 0.5))
        XCTAssertFalse(plusButton.exists)
        XCTAssertFalse(minusButton.exists)
    }

}


extension Data_Pill_UI_Tests {
    
    func printUITree() {
        print(app.debugDescription)
    }
    
    //    func testLaunchPerformance() throws {
    //        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
    //            // This measures how long it takes to launch your application.
    //            measure(metrics: [XCTApplicationLaunchMetric()]) {
    //                XCUIApplication().launch()
    //            }
    //        }
    //    }
    
    
    enum `Type` {
        case button
        case text
        case image
    }
    
    func getElement(type: `Type`, identifier: String?, label: String?) -> XCUIElement {
        var query: XCUIElementQuery!
        
        switch type {
        case .text:
            query = app.staticTexts
            break
        case .button:
            query = app.buttons
            break
        case .image:
            query = app.images
        }
            
        if let identifier {
            /// [cd] case and diacritic (glyph added to word for pronounciation) insensitive
            query = query.matching(.init(format: "identifier == [cd] %@", identifier))
        }
        if let label {
            query = query.matching(.init(format: "label == [cd] %@", label))
        }
                
        return query.element
    }
    
    func hasElements(identifier: String) -> Bool {
        let query = app.otherElements.matching(.init(format: "identifier == [cd] %@", identifier))
        return query.count > 0
    }
    
}

extension XCUIElement {
    
    func forceTap() {
        if self.isHittable {
            self.tap(); return
        }
        let coordinate = self.coordinate(withNormalizedOffset: .zero)
        coordinate.tap()
    }
    
    
    func isVisible() -> Bool {
        guard self.exists, !self.frame.isEmpty else {
            return false
        }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(self.frame)
    }
    
}
