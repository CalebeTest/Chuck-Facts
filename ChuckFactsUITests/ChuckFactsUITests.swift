//
//  ChuckFactsUITests.swift
//  ChuckFactsUITests
//
//  Created by Calebe Emerik  | Stone on 15/03/18.
//  Copyright © 2018 Stone Pagamentos. All rights reserved.
//

import XCTest
import Nimble
import Swifter

final class ChuckFactsUITests: XCTestCase {
	
	private let stubber = HTTPStubber()
	
	private var app: XCUIApplication!
	private var screen: FactScreen!
	
	private func searchSomeFactAndWait(for result: FactScreenStateMock) {
		let text = stubber.setStub(for: result)
		screen.textField.typeText(text)
		screen.searchButton.tap()
	}
	
	override func setUp() {
		super.setUp()
		
		continueAfterFailure = false
		
		app = XCUIApplication()
		screen = FactScreen(app: app)
		stubber.setUp()
		
		app.launchArguments.append("--uitesting")
		app.launch()
	}
	
	override func tearDown() {
		screen = nil
		app = nil
		stubber.tearDown()
		
		super.tearDown()
	}
	
	func test_TextField_Should_BeEnabled_When_AppStarts() {
		
		expect(self.screen.textField.isEnabled).to(beTrue())
	}
	
	func test_SearchSomeFactWith_Success_AndShouldShow_AListWithTwoFacts() {
		
		searchSomeFactAndWait(for: .success)
		
		expect(self.screen.tableView.cells.count).toEventually(equal(2), timeout: 1)
	}
	
	func test_SearchSomeFactWith_SuccessWithEmptyResult_AndShow_EmptyResultView() {
		
		searchSomeFactAndWait(for: .successWithEmptyResult)
		
		expect(self.screen.emptyResult.exists).toEventually(beTrue(), timeout: 1)
	}
	
	func test_SearchSomeFactWith_NoResultsForTerm_AndShow_NoResultsForTermView() {
		
		searchSomeFactAndWait(for: .noResultsForTerm)
		
		expect(self.screen.emptyResult.exists).toEventually(beTrue(), timeout: 1)
	}
	
	func test_SearchSomeFactWith_InvalidTerm_AndShow_InvalidTermView() {
		
		searchSomeFactAndWait(for: .invalidTerm)
		
		expect(self.screen.invalidTerm.exists).toEventually(beTrue(), timeout: 1)
	}
	
	func test_SearchSomeFactWith_InternalError_AndShow_InternalErrorView() {
		
		searchSomeFactAndWait(for: .unknown)
		
		expect(self.screen.internalError.exists).toEventually(beTrue(), timeout: 1)
	}
}

extension ChuckFactsUITests {
	
	struct FactScreen {
		
		let textField: XCUIElement
		let searchButton: XCUIElement
		let tableView: XCUIElement
		let emptyResult: XCUIElement
		let invalidTerm: XCUIElement
		let noConnection: XCUIElement
		let internalError: XCUIElement
		
		init(app: XCUIApplication) {
			textField = app.textFields["FactTextField"]
			searchButton = app.keyboards.buttons["Search"]
			tableView = app.tables["FactTableView"]
			emptyResult = app.otherElements["FactEmptyResult"]
			invalidTerm = app.otherElements["FactInvalidTerm"]
			noConnection = app.otherElements["FactConnectionError"]
			internalError = app.otherElements["FactInternalError"]
		}
	}
}
