//
//  Wunderlist2_0UITests.swift
//  Wunderlist2.0UITests
//
//  Created by Claudia Contreras on 6/19/20.
//  Copyright © 2020 thecoderpilot. All rights reserved.
//

import XCTest
@testable import Wunderlist2_0

class Wunderlist2UITests: XCTestCase {

    override func setUp() {
        super.setUp()
        let app = XCUIApplication()
        app.launchArguments.append("UITesting")
    }
    
    func testSignInButtonExample() throws {
        let app = XCUIApplication()
        app.launch()
        
        app/*@START_MENU_TOKEN@*/.buttons["Sign In"]/*[[".segmentedControls.buttons[\"Sign In\"]",".buttons[\"Sign In\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssert(app.staticTexts["Sign In"].exists)
    }
    
    func testSignInandOutButtonExample() throws {
        let app = XCUIApplication()
        app.launch()
        
        app/*@START_MENU_TOKEN@*/.buttons["Sign In"]/*[[".segmentedControls.buttons[\"Sign In\"]",".buttons[\"Sign In\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        XCTAssert(app.staticTexts["Sign In"].exists)
        app.buttons["Sign Up"].tap()
        XCTAssert(app.staticTexts["Sign Up"].exists)
    }

    func testuserName() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        app/*@START_MENU_TOKEN@*/.buttons["Sign In"]/*[[".segmentedControls.buttons[\"Sign In\"]",".buttons[\"Sign In\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()

        let userName = app.textFields["username"]
        userName.tap()
        userName.typeText("clmaciel1")
        
        XCTAssertEqual(userName.value as! String, "clmaciel1")
        
    }
    
    func testPassword() throws {
        let app = XCUIApplication()
        app.launch()
        
        let password = app.textFields["password"]
        password.tap()
        password.typeText("clmaciel1")
        
        XCTAssertEqual(password.value as! String, "clmaciel1")
    }
    
    func testSecurefield() throws {
        let app = XCUIApplication()
        app.launch()

        let password = app.textFields["password"]
        password.tap()
        password.typeText("clmaciel1")
        
        XCTAssertFalse(password.secureTextFields["password"].exists)
    }
}
////if which swiftlint >/dev/null; then
//  swiftlint
//else
//  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
//fi

