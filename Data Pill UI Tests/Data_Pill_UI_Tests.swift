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
    
    // MARK: Guide
    func test_a_guide() throws {
        try delete_app(app)
        app.launch()
        try test_guide(isPlan: false)
        
        try delete_app(app)
        app.launch()
        try test_guide(isPlan: true)
    }
    
    func test_guide(isPlan: Bool) throws {
        
        let headerLabel = app.staticTexts["Get Started"]
        let titleLabel = app.staticTexts["Do you have a Data Plan?"]
        let descriptionLabel = app.staticTexts["A Data Plan is a subscription service where you pay every period to use a fixed amount of mobile data. "]
        let yepButton = app.buttons["Yep"]
        let nopeButton = app.buttons["Nope"]
        
        XCTAssert(headerLabel.exists)
        XCTAssert(titleLabel.exists)
        XCTAssert(descriptionLabel.exists)
        XCTAssert(yepButton.waitForExistence(timeout: 4.0))
        XCTAssert(nopeButton.waitForExistence(timeout: 4.0))
                
        if isPlan {
            
            yepButton.tap()
            let yepLabel = app.staticTexts["Yep."]
            let yepDescLabel = app.staticTexts["Set the amount of data in your plan and the period it starts and ends."]
         
            XCTAssert(yepLabel.exists)
            XCTAssert(yepDescLabel.exists)
            
        } else {
            
            nopeButton.tap()
            let nopeLabel = app.staticTexts["Nope."]
            let nopeDesc1Label = app.staticTexts["Data Pill will just monitor and track your daily mobile data."]
            let nopeDesc2Label = app.staticTexts["If you ever subscribe to a plan in the future, toggle Data Plan."]
            
            XCTAssert(nopeLabel.exists)
            XCTAssert(nopeDesc1Label.exists)
            XCTAssert(nopeDesc2Label.exists)
        }
                
        let startButton = app.buttons["Start"]
        
        XCTAssert(startButton.waitForExistence(timeout: 5.0))
        
        startButton.tap()
    }
    
    // MARK: - Pill
    func test_b_pill() throws {
        let identifier = "history"

        let pillButton = getElement(type: .button, identifier: "pill", label: nil)
        XCTAssert(pillButton.waitForExistence(timeout: 1.0))
        
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
        
        XCTAssertFalse(dayPercentageLabel.exists)
        XCTAssertFalse(dayLabel.exists)
        
        closeButton.tap()
        
        XCTAssertFalse(hasElements(identifier: identifier))
    }
    
    // MARK: - Used Card
    func test_c_used() throws {
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
    func test_d_usage() throws {
        try test_usage(isPlan: true)
    }
    
    func test_usage(isPlan: Bool) throws {
        let planLabel = isPlan ? "Plan" : "NA"
        
        let usageLabel = getElement(type: .text, identifier: "usage", label: "USAGE")
        let planToggleButton = getElement(type: .button, identifier: "usage", label: planLabel)
        let dailyToggleButton = getElement(type: .button, identifier: "usage", label: "Daily")
        
        XCTAssert(usageLabel.exists)
        XCTAssert(planToggleButton.exists)
        XCTAssert(dailyToggleButton.exists)
        
        planToggleButton.tap()
        dailyToggleButton.tap()
    }
    
    // MARK: - Period Card
    func test_e_period() throws {
       try test_period(isPlan: true)
    }
    
    func test_period(isPlan: Bool) throws {
        
        let periodCardLabel = getElement(type: .text, identifier: "period", label: "PERIOD")
        
        XCTAssert(periodCardLabel.exists)
        
        if !isPlan {
            let naOptionButton = getElement(type: .button, identifier: "period", label: "NA")
            
            XCTAssert(naOptionButton.exists)
            
            return
        }

        let manualOptionButton = getElement(type: .button, identifier: "period", label: "Manual")
        
        XCTAssert(manualOptionButton.exists)
        
        try toggle_auto_period()
        
        return
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
    func test_f_data_plan() throws {
        let identifier = "dataPlan"

        let dataPlanLabel = getElement(type: .text, identifier: identifier, label: "Data Plan")

        XCTAssert(dataPlanLabel.exists)
        
        let planToggleButton = getElement(type: .button, identifier: identifier, label: "slideToggle")
        let editPeriodButton = getElement(type: .button, identifier: identifier, label: "period")
        let editPeriodButtonImage = editPeriodButton.images["Right Arrow Icon"]

        XCTAssert(planToggleButton.exists)
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
        try toggleDataPlan(planToggleButton, editPeriodButton, editAmountButton)
    }
    
    func toggleDataPlan(
        _ toggleButton: XCUIElement,
        _ editPeriodButton: XCUIElement,
        _ editAmountButton: XCUIElement
    ) throws {
        
        toggleButton.tap()
                
        XCTAssertFalse(editPeriodButton.exists)
        XCTAssertFalse(editAmountButton.exists)
        
        try test_usage(isPlan: false)
        try test_period(isPlan: false)
        try test_plan_limit(isPlan: false)
        
        toggleButton.tap()

        XCTAssert(editPeriodButton.exists)
        XCTAssert(editAmountButton.exists)
        
        try test_usage(isPlan: true)
        try test_period(isPlan: true)
        try test_plan_limit(isPlan: true)
    }
    
    // MARK: - Plan Limit
    func test_g_plan_limit() throws {
        try test_plan_limit(isPlan: true)
    }
    
    func test_plan_limit(isPlan: Bool) throws {
        let identifier = "planLimit"
        
        let planLimitLabel = app.staticTexts
            .matching(.init(format: "identifier == [cd] %@", identifier))
            .containing(.init(format: "label BEGINSWITH 'Plan'"))
            .containing(.init(format: "label ENDSWITH 'Limit'"))
            .element
        
        if isPlan {
            XCTAssert(planLimitLabel.exists)
        } else {
            XCTAssertFalse(planLimitLabel.exists)
        }
        
        let limitAmount = getElement(type: .text, identifier: identifier, label: "limitAmount")
        let limitUnit = getElement(type: .text, identifier: identifier, label: "limitUnit")
        let editButton = getElement(type: .button, identifier: identifier, label: "Right Arrow Icon")

        if isPlan {
            XCTAssert(limitAmount.exists)
            XCTAssert(limitUnit.exists)
            XCTAssert(editButton.exists)
        } else {
            XCTAssertFalse(limitAmount.exists)
            XCTAssertFalse(limitUnit.exists)
            XCTAssertFalse(editButton.exists)
        }
        
        if isPlan {
            try edit_value_with_stepper_then_save(editButton, identifier: identifier, title: "Plan Limit")
            try edit_then_show_stepper_values(editButton, identifier: identifier)
            try edit_value_exceeds_data_amount(editButton, identifier: identifier)
        }
    }
    
    // MARK: - Daily Limit
    func test_h_daily_limit() throws {
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
        try edit_value_exceeds_data_amount(editButton, identifier: identifier)
    }
    
    // MARK: - Reusables
    func edit_period_with_picker_then_save(_ editButton: XCUIElement, identifier: String) throws {
        // show edit input
        editButton.tap()
        
        let saveButton = app.buttons["Save"]
        let periodLabel = getElement(type: .text, identifier: identifier, label: "Period")
        let fromLabel = getElement(type: .text, identifier: identifier, label: "title")
        let toLabel = getElement(type: .text, identifier: identifier, label: "title")
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
    }
    
    func edit_period_then_show_date_picker_then_save(_ editButton: XCUIElement, identifier: String) throws {
        // show edit input
        editButton.tap()
        
        let startDateButton = getElement(type: .button, identifier: identifier, label: nil, boundBy: 3)
        let endDateButton = getElement(type: .button, identifier: identifier, label: nil, boundBy: 4)

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
        let titleLabel = getElement(type: .text, identifier: identifier, label: title)
        let plusButton = getElement(type: .button, identifier: identifier, label: "Plus")
        let minusButton = getElement(type: .button, identifier: identifier, label: "Minus")

        XCTAssert(saveButton.waitForExistence(timeout: 0.5))
        XCTAssert(titleLabel.exists)
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
        
        let saveButton = app.buttons["Save"]
        let minusButton = getElement(type: .button, identifier: identifier, label: "Minus")
        let plusButton = getElement(type: .button, identifier: identifier, label: "Plus")
        
        XCTAssert(saveButton.waitForExistence(timeout: 0.5))
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
        
        // save
        saveButton.tap()
        
        XCTAssertFalse(saveButton.waitForExistence(timeout: 0.5))
        XCTAssertFalse(plusButton.exists)
        XCTAssertFalse(minusButton.exists)
    }
    
    func edit_value_exceeds_data_amount(_ editButton: XCUIElement, identifier: String) throws {
        // show edit input
        if !editButton.isVisible() {
            app.swipeUp()
        }
        
        editButton.tap()
        
        let saveButton = app.buttons["Save"]
        let plusButton = getElement(type: .button, identifier: identifier, label: "Plus")
        let minusButton = getElement(type: .button, identifier: identifier, label: "Minus")

        XCTAssert(saveButton.exists)
        XCTAssert(plusButton.exists)
        XCTAssert(minusButton.exists)
        
        // stepper: increase limit by 1
        plusButton.tap()
        
        // stepper: exceeds displays error
        let toastLabel = getElement(type: .text, identifier: nil, label: "Exceeds maximum data amount")
        let toastIcon = getElement(type: .image, identifier: nil, label: "Warning Icon")
                        
        XCTAssert(toastLabel.waitForExistence(timeout: 3.0))
        XCTAssert(toastIcon.exists)
        
        // text field: 1
        let textField = getElement(type: .textField, identifier: identifier, label: "valueInput")
        
        XCTAssert(textField.exists)
        
        textField.tap()
        
        try highlightAndClearTextField(from: textField)
        try typeNumber(1.0)

        // text field: exceeds disables save button
        saveButton.tap()
        
        XCTAssert(plusButton.exists)
        XCTAssert(minusButton.exists)
        
        // text field: reset and save
        minusButton.tap()
        saveButton.tap()

        XCTAssertFalse(plusButton.exists)
        XCTAssertFalse(minusButton.exists)
        
        // check if error is gone
        editButton.tap()
        
        XCTAssertFalse(toastLabel.exists)
        XCTAssertFalse(toastIcon.exists)
    }
    
    func delete_app(_ app: XCUIApplication) throws {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        
        app.terminate()

        // make sure widget is removed as it can query 2 icons
        let icon = springboard.icons["Data Pill"]
                
        if !icon.exists {
            return
        }
        
        XCTAssert(icon.exists)
        
        let iconFrame = icon.frame
        let springboardFrame = springboard.frame
        icon.press(forDuration: 5)

        let minusButton = springboard.coordinate(
            withNormalizedOffset:
                CGVector(
                    dx: (iconFrame.minX + 3) / springboardFrame.maxX,
                    dy: (iconFrame.minY + 3) / springboardFrame.maxY
                )
        )
        
        minusButton.tap()

        let deleteAppButton = springboard.alerts.buttons["Delete App"]
        
        XCTAssert(deleteAppButton.waitForExistence(timeout: 1.0))
        
        deleteAppButton.tap()
        
        let deleteButton = springboard.alerts.buttons["Delete"]

        XCTAssert(deleteButton.waitForExistence(timeout: 1.0))
        
        deleteButton.tap()
    }
}


extension Data_Pill_UI_Tests {
    
    func printUITree() {
        print(app.debugDescription)
    }
    
    enum `Type` {
        case button
        case text
        case image
        case textField
    }
    
    func getElement(type: `Type`, identifier: String?, label: String?, boundBy: Int? = nil) -> XCUIElement {
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
            break
        case .textField:
            query = app.textFields
        }
            
        if let identifier {
            /// [cd] case and diacritic (glyph added to word for pronounciation) insensitive
            /// quotes are retained
            query = query.matching(.init(format: "identifier == [cd] %@", identifier))
        }
        if let label {
            query = query.matching(.init(format: "label == [cd] %@", label))
        }
                
        if let boundBy {
            // print("query ", query)
            return query.element(boundBy: boundBy)
        }
        
        // print("count: ", query.count)
        return query.element
    }
    
    func hasElements(identifier: String) -> Bool {
        let query = app.otherElements.matching(.init(format: "identifier == [cd] %@", identifier))
        return query.count > 0
    }
    
    /// Type Numbers on Number Pad Keyboard Input
    /// - Parameter numericalValue : A value to type
    func typeNumber(_ numericValue: Double) throws {
        // print(app.keys.debugDescription)
        let number = "\(numericValue)"
        
        for index in number.indices {
            let char = number[index]
            let keyButton = app.keys[String(char)]
            XCTAssert(keyButton.exists)
            keyButton.tap()
        }
    }
    
    func highlightAndClearTextField(from element: XCUIElement) throws {
        printUITree()
        let deleteButton = app.keys["Delete"]
        XCTAssert(deleteButton.exists)
        element.tap(withNumberOfTaps: 2, numberOfTouches: 1)
        deleteButton.tap()
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
