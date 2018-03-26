//
//  FactScreenStateMock.swift
//  ChuckFactsUITests
//
//  Created by Calebe Emerik  | Stone on 26/03/18.
//  Copyright © 2018 Stone Pagamentos. All rights reserved.
//

import Foundation
import Swifter

enum FactScreenStateMock: String {
	case success
	case successWithEmptyResult
	case noResultsForTerm
	case invalidTerm
	case unknown
}

extension FactScreenStateMock {
	
	var fileURL: URL {
		let bundle = Bundle(for: type(of: HTTPStubber.self))
		let filePath = bundle.path(forResource: self.filename, ofType: "json")!
		return URL(fileURLWithPath: filePath)
	}
	
	var responseData: Data {
		return try! Data(contentsOf: fileURL, options: .uncached)
	}
	
	var filename: String {
		switch self {
		case .successWithEmptyResult:
			return "SuccessWithEmptyResult"
		default:
			return rawValue.capitalized
		}
	}
	
	var url: String {
		return "/\(rawValue)"
	}
	
	var statusCode: Int {
		switch self {
		case .success, .successWithEmptyResult:
			return 200
		case .noResultsForTerm:
			return 422
		case .invalidTerm:
			return 404
		case .unknown:
			return 500
		}
	}
	
	var httpResponse: HttpResponse {
		switch self {
		case .success, .successWithEmptyResult:
			return .raw(self.statusCode, "", nil, { writer in
				try! writer.write(self.responseData)
			})
		case .invalidTerm, .noResultsForTerm, .unknown:
			return .raw(self.statusCode, "", nil, nil)
		}
	}
	
	var response: ((HttpRequest) -> HttpResponse) {
		let response: ((HttpRequest) -> HttpResponse) = { _ in
			return self.httpResponse
		}
		return response
	}
}
