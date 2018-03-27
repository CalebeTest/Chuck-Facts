//
//  HTTPStuber.swift
//  ChuckFactsUITests
//
//  Created by Calebe Emerik  | Stone on 26/03/18.
//  Copyright © 2018 Stone Pagamentos. All rights reserved.
//

import Foundation
import Swifter

final class HTTPStubber {
	
	private let server = HttpServer()
	
	func setUp() {
		try! server.start()
	}
	
	func tearDown() {
		server.stop()
	}
	
	func setStub(for type: FactScreenStateMock) -> String {
		server.GET[type.url] = type.response
		return type.url
	}
}
