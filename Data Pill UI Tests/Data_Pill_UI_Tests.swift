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
    
    // MARK: - Pill
    func test_pill() throws {
        let identifier = "history"

        let pillButton = getElement(type: .button, identifier: "pill", label: "TODAY")
        XCTAssert(pillButton.exists)
        
        try open_history_then_close(pillButton, identifier: identifier)
    }
    
    func open_history_then_close(_ pillButton: XCUIElement, identifier: String) throws {
        pillButton.tap()

        // Top Bar
        let weekLabel = getElement(type: .text, identifier: identifier, label: "This Week")
        let closeButton = getElement(type: .button, identifier: identifier, label: "X Mark Icon")
        
        XCTAssert(weekLabel.exists)
        XCTAssert(closeButton.exists)
        
        // Day Pills
        let dayPercentageLabel = getElement(type: .text, identifier: identifier, label: "0%")
        let dayLabel = getElement(type: .text, identifier: identifier, label: "TODAY")
        
        XCTAssert(dayPercentageLabel.exists)
        XCTAssert(dayLabel.exists)
        
        closeButton.tap()
        
        XCTAssertFalse(hasElements(identifier: identifier))
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
        let identifier = "dataPlan"
        
        let dataPlanLabel = getElement(type: .text, identifier: identifier, label: "Data Plan")
        
        XCTAssert(dataPlanLabel.exists)
                
        let editPeriodButton = getElement(type: .button, identifier: identifier, label: "period")
        let editPeriodButtonImage = editPeriodButton.images["Right Arrow Icon"]
        
        XCTAssert(editPeriodButton.exists)
        XCTAssert(editPeriodButtonImage.exists)

        let editAmountButton = getElement(type: .button, identifier: identifier, label: "amount")
        let editAmountButtonImage = editAmountButton.images["Right Arrow Icon"]
        
        XCTAssert(editAmountButton.exists)
        XCTAssert(editAmountButtonImage.exists)

        try edit_period_with_picker_then_save(editPeriodButton, identifier: identifier)
        try edit_period_then_show_date_picker_then_save(editPeriodButton, identifier: identifier)
        try edit_value_with_stepper_then_save(editAmountButton, identifier: identifier, title: "Data Amount")
        try edit_then_show_stepper_values(editAmountButton, identifier: identifier)
    }
    
    // MARK: - Plan Limit
    func test_plan_limit() throws {
        let identifier = "planLimit"
        
        let planLimitLabel = app.staticTexts
            .matching(.init(format: "identifier == [cd] %@", identifier))
            .containing(.init(format: "label BEGINSWITH 'Plan'"))
            .containing(.init(format: "label ENDSWITH 'Limit'"))
            .element
        
        XCTAssert(planLimitLabel.exists)
        
        let limitAmount = getElement(type: .text, identifier: identifier, label: "limitAmount")
        let limitUnit = getElement(type: .text, identifier: identifier, label: "limitUnit")
        let editButton = getElement(type: .button, identifier: identifier, label: "Right Arrow Icon")

        XCTAssert(limitAmount.exists)
        XCTAssert(limitUnit.exists)
        XCTAssert(editButton.exists)
        
        try edit_value_with_stepper_then_save(editButton, identifier: identifier, title: "Plan Limit")
        try edit_then_show_stepper_values(editButton, identifier: identifier)
    }
    
    // MARK: - Daily Limit
    func test_daily_limit() throws {
        let identifier = "dailyLimit"
        
        let dailyLimitLabel = app.staticTexts
            .matching(.init(format: "identifier == [cd] %@", identifier))
            .containing(.init(format: "label BEGINSWITH 'Daily'"))
            .containing(.init(format: "label ENDSWITH 'Limit'"))
            .element
        
        XCTAssert(dailyLimitLabel.exists)
        
        let limitAmount = getElement(type: .text, identifier: identifier, label: "limitAmount")
        let limitUnit = getElement(type: .text, identifier: identifier, label: "limitUnit")
        let editButton = getElement(type: .button, identifier: identifier, label: "Right Arrow Icon")

        XCTAssert(limitAmount.waitForExistence(timeout: 0.5))
        XCTAssert(limitUnit.exists)
        XCTAssert(editButton.exists)
        
        try edit_value_with_stepper_then_save(editButton, identifier: identifier, title: "Daily Limit")
        try edit_then_show_stepper_values(editButton, identifier: identifier)
    }
    
    // MARK: - Reusables
    func edit_period_with_picker_then_save(_ editButton: XCUIElement, identifier: String) throws {
        // show edit input
        editButton.tap()
        
        let saveButton = app.buttons["Save"]
        let periodLabel = getElement(type: .text, identifier: identifier, label: "Period")
        let fromLabel = getElement(type: .text, identifier: identifier, label: "From")
        let toLabel = getElement(type: .text, identifier: identifier, label: "To")
        let numberOfDaysLabel = getElement(type: .text, identifier: identifier, label: "secondaryLabel")

        XCTAssert(saveButton.waitForExistence(timeout: 0.5))
        XCTAssert(periodLabel.exists)
        XCTAssert(fromLabel.exists)
        XCTAssert(toLabel.exists)
        XCTAssert(numberOfDaysLabel.exists)
        
        // save
        saveButton.tap()
                
        XCTAssertFalse(saveButton.waitForExistence(timeout: 0.5))
        XCTAssertFalse(periodLabel.exists)
        XCTAssertFalse(fromLabel.exists)
        XCTAssertFalse(toLabel.exists)
        XCTAssertFalse(numberOfDaysLabel.exists)
    }
    
    func edit_period_then_show_date_picker_then_save(_ editButton: XCUIElement, identifier: String) throws {
        // show edit input
        editButton.tap()
        
        let startDateButton = getElement(type: .button, identifier: identifier, label: "From Button")
        let endDateButton = getElement(type: .button, identifier: identifier, label: "To Button")

        XCTAssert(startDateButton.waitForExistence(timeout: 0.5))
        XCTAssert(endDateButton.exists)

        // show start date picker then done
        startDateButton.tap()
        
        let doneButton = app.buttons["Done"]
        let datePicker = app.datePickers.element
        
        XCTAssert(doneButton.waitForExistence(timeout: 0.5))
        XCTAssert(datePicker.exists)
        
        doneButton.tap()
        
        XCTAssertFalse(doneButton.waitForExistence(timeout: 0.5))
        XCTAssertFalse(datePicker.exists)
        
        // show end date picker then done
        endDateButton.tap()
        
        XCTAssert(doneButton.waitForExistence(timeout: 0.5))
        XCTAssert(datePicker.exists)
        
        doneButton.tap()
        
        XCTAssertFalse(doneButton.waitForExistence(timeout: 0.5))
        XCTAssertFalse(datePicker.exists)

        // save
        let saveButton = app.buttons["Save"]
        
        XCTAssert(saveButton.exists)
        
        saveButton.tap()
        
        XCTAssertFalse(saveButton.waitForExistence(timeout: 0.5))
    }
    
    func edit_value_with_stepper_then_save(_ editButton: XCUIElement, identifier: String, title: String) throws {
        // show edit input
        if !editButton.isVisible() {
            app.swipeUp()
        }
        
        editButton.tap()
                        
        let saveButton = app.buttons["Save"]
        let dailyLimitLabel = getElement(type: .text, identifier: identifier, label: title)
        let plusButton = getElement(type: .button, identifier: identifier, label: "Plus")
        let minusButton = getElement(type: .button, identifier: identifier, label: "Minus")

        XCTAssert(saveButton.waitForExistence(timeout: 0.5))
        XCTAssert(dailyLimitLabel.exists)
        XCTAssert(plusButton.exists)
        XCTAssert(minusButton.exists)
        
        // save
        saveButton.tap()
        
        XCTAssertFalse(saveButton.waitForExistence(timeout: 0.5))
        XCTAssertFalse(plusButton.exists)
        XCTAssertFalse(minusButton.exists)
    }
    
    func edit_then_show_stepper_values(_ editButton: XCUIElement, identifier: String) throws {
        // show edit input
        if !editButton.isVisible() {
            app.swipeUp()
        }
        
        editButton.tap()
        
        let minusButton = getElement(type: .button, identifier: identifier, label: "Minus")
        let plusButton = getElement(type: .button, identifier: identifier, label: "Plus")
        
        XCTAssert(minusButton.exists)
        XCTAssert(plusButton.exists)
        
        // show minus stepper values then close
        minusButton.press(forDuration: 1.0)

        let minusCloseButton = getElement(type: .button, identifier: identifier, label: "minus / Rotated Plus Icon")
        let value1Button = getElement(type: .button, identifier: identifier, label: "0.1")
        let value2Button = getElement(type: .button, identifier: identifier, label: "1")

        XCTAssert(minusCloseButton.exists)
        XCTAssert(value1Button.exists)
        XCTAssert(value2Button.exists)

        minusCloseButton.tap()
        
        XCTAssertFalse(minusCloseButton.exists)
        XCTAssertFalse(value1Button.exists)
        XCTAssertFalse(value2Button.exists)

        // show plus stepper values then close
        plusButton.press(forDuration: 1.0)
        
        let plusCloseButton = getElement(type: .button, identifier: identifier, label: "plus / Rotated Plus Icon")
        
        XCTAssert(plusCloseButton.exists)
        XCTAssert(value1Button.exists)
        XCTAssert(value2Button.exists)
        
        plusCloseButton.tap()
        
        XCTAssertFalse(plusCloseButton.exists)
        XCTAssertFalse(value1Button.exists)
        XCTAssertFalse(value2Button.exists)

        // show minus stepper values then show plus stepper value
        minusButton.press(forDuration: 1.0)
        
        XCTAssert(minusCloseButton.exists)
        
        plusButton.press(forDuration: 1.0)
        
        XCTAssertFalse(minusCloseButton.exists)
        XCTAssert(plusCloseButton.exists)
        
        // then show minus stepper value
        minusButton.press(forDuration: 1.0)
        
        XCTAssertFalse(plusCloseButton.exists)
        XCTAssert(minusCloseButton.exists)
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
                
        print("count: ", query.count)
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
