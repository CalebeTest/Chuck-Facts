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
	
	private let dynamicStubs = HTTPDynamicStubs()
	
	private var app: XCUIApplication!
	private var screen: FactScreen!
	
	private func setScreenState(to state: String) {
		app.launchEnvironment.updateValue(state, forKey: "screen_mock_state")
	}
	
	private func searchSomeFactAndWaitFor(_ state: String) {
		setScreenState(to: state)
		
		app.launch()
		
		screen.textField.typeText("Some Fact...")
		screen.searchButton.tap()
	}
	
	override func setUp() {
		super.setUp()
		
		continueAfterFailure = false
		
		app = XCUIApplication()
		
		screen = FactScreen(app: app)
		
		dynamicStubs.setUp()
		
		app.launchArguments.append("--uitesting")
		app.launch()
	}
	
	override func tearDown() {
		screen = nil
		app = nil
		dynamicStubs.tearDown()
		
		super.tearDown()
	}
	
//	func test_TextField_Should_BeEnabled_When_AppStarts() {
//
//		setScreenState(to: "success")
//
//		app.launch()
//
//		expect(self.screen.textField.isEnabled).to(beTrue())
//	}
//
//	func test_SearchSomeFactWith_Success_AndShouldShow_AListWithTwoFacts() {
//
//		searchSomeFactAndWaitFor("success")
//
//		expect(self.screen.tableView.cells.count).toEventually(equal(2), timeout: 1)
//	}
//
//	func test_SearchSomeFactWith_SuccessWithEmptyResult_AndShow_EmptyResultView() {
//
//		searchSomeFactAndWaitFor("successWithEmptyResult")
//
//		expect(self.screen.emptyResult.exists).toEventually(beTrue(), timeout: 1)
//	}
//
//	func test_SearchSomeFactWith_NoResultsForTerm_AndShow_NoResultsForTermView() {
//
//		searchSomeFactAndWaitFor("noResultsForTerm")
//
//		expect(self.screen.emptyResult.exists).toEventually(beTrue(), timeout: 1)
//	}
//
//	func test_SearchSomeFactWith_InvalidTerm_AndShow_InvalidTermView() {
//
//		searchSomeFactAndWaitFor("invalidTerm")
//
//		expect(self.screen.invalidTerm.exists).toEventually(beTrue(), timeout: 1)
//	}
//
//	func test_SearchSomeFactWith_NoConnection_AndShow_NoConnectionView() {
//
//		searchSomeFactAndWaitFor("noConnection")
//
//		expect(self.screen.noConnection.exists).toEventually(beTrue(), timeout: 2)
//	}
//
//	func test_SearchSomeFactWith_InternalError_AndShow_InternalErrorView() {
//
//		searchSomeFactAndWaitFor("internal")
//
//		expect(self.screen.internalError.exists).toEventually(beTrue(), timeout: 1)
//	}
	
	
	
	
	
	
	func test_asd() {
		
		dynamicStubs.setupStub(url: "/test", filename: "Test")
		
		screen.textField.typeText("/test")
		screen.searchButton.tap()
		
		expect(self.screen.tableView.cells.count).toEventually(equal(2), timeout: 2)
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

enum HTTPMethod {
	case GET
}

class HTTPDynamicStubs {
	
	var server = HttpServer()
	
	func setUp() {
		setupInitialStubs()
		try! server.start()
	}
	
	func tearDown() {
		server.stop()
	}
	
	func setupInitialStubs() {
		// Setting up all the initial mocks from the array
		for stub in initialStubs {
			setupStub(url: stub.url, filename: stub.jsonFilename, method: stub.method)
		}
	}
	
	public func setupStub(url: String, filename: String, method: HTTPMethod = .GET) {
		let testBundle = Bundle(for: type(of: self))
		let filePath = testBundle.path(forResource: filename, ofType: "json")
		let fileUrl = URL(fileURLWithPath: filePath!)
		let data = try! Data(contentsOf: fileUrl, options: .uncached)
		// Looking for a file and converting it to JSON
//		let json = dataToJSON(data: data)
		
		// Swifter makes it very easy to create stubbed responses
		let response: ((HttpRequest) -> HttpResponse) = { _ in
			return HttpResponse.raw(200, "IDK", [:], { writer in
				return try writer.write(data)
			})
//			return HttpResponse.ok(HttpResponseBody.custom(data, { rawData -> String in
//				fatalError("IDK")
//			}))
//			return HttpResponse.ok(.json(data as AnyObject))
		}
		
		switch method  {
		case .GET:
			server.GET[url] = response
		}
	}
	
//	func dataToJSON(data: Data) -> Any? {
//		do {
//			return try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
//		} catch let myJSONError {
//			print(myJSONError)
//		}
//		return nil
//	}
}

struct HTTPStubInfo {
	let url: String
	let jsonFilename: String
	let method: HTTPMethod
}

let initialStubs = [
	HTTPStubInfo(url: "http://localhost:8080/test", jsonFilename: "Test", method: .GET),
]
