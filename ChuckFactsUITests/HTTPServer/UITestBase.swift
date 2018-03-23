//
//  UITestBase.swift
//  ChuckFactsUITests
//
//  Created by Calebe Emerik  | Stone on 23/03/18.
//  Copyright © 2018 Stone Pagamentos. All rights reserved.
//

import XCTest
import Embassy
import Ambassador

class UITestBase: XCTestCase {
	
	let port = 8080
	var router: Router!
	var eventLoop: EventLoop!
	var server: HTTPServer!
	var app: XCUIApplication!
	
	var eventLoopThreadCondition: NSCondition!
	var eventLoopThread: Thread!
	
	override func setUp() {
		super.setUp()
		
		setupWebApp()
		setupApp()
	}
	
	// setup the Embassy web server for testing
	private func setupWebApp() {
		
		eventLoop = try! SelectorEventLoop(selector: try! KqueueSelector())
		router = DefaultRouter()
		server = DefaultHTTPServer(eventLoop: eventLoop, port: port, app: router.app)
		
		// Start HTTP server to listen on the port
		try! server.start()
		
		eventLoopThreadCondition = NSCondition()
		eventLoopThread = Thread(target: self, selector: #selector(runEventLoop), object: nil)
		eventLoopThread.start()
	}
	
	// set up XCUIApplication
	private func setupApp() {
		app = XCUIApplication()
		app.launchEnvironment["RESET_LOGIN"] = "1"
		app.launchEnvironment["ENVOY_BASEURL"] = "http://localhost:\(port)"
	}
	
	override func tearDown() {
		super.tearDown()
		
		app.terminate()
		server.stopAndWait()
		eventLoopThreadCondition.lock()
		eventLoop.stop()
	}
	
	@objc private func runEventLoop() {
		eventLoop.runForever()
		eventLoopThreadCondition.lock()
		eventLoopThreadCondition.signal()
		eventLoopThreadCondition.unlock()
	}
}

class DefaultRouter: Router {
	
	static let fetchUsersPath = "/api/v2/users"
	
	override init() {
		super.init()
		
		self[DefaultRouter.fetchUsersPath] = DelayResponse(JSONResponse(handler: ({ environ in
			return [
				["id": "01", "name": "John"],
				["id": "02", "name": "Tom"]
			]
		})))
	}
}

class MyUITests: UITestBase {
	
	func testUserList() {
		
		router[DefaultRouter.fetchUsersPath] = DelayResponse(JSONResponse(handler: { _ in
			return [
				["id": "01", "name": "John"],
				["id": "02", "name": "Tom"]
			]
		}))
		
		app.launch()
		
		let webApp = router[DefaultRouter.fetchUsersPath]

		print("lol")
	}
}
