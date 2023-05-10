//
//  StringExtensions_Tests.swift
//  Oak for Reddit Unit Tests
//
//  Created by Francesco Ghianda on 09/05/23.
//

import XCTest

class StringExtensions_Tests: XCTestCase {

    func test_StringExtensions_firstUppercased() {
        
        let testString = "test string"
        XCTAssertEqual(testString.firstUppercased(), "Test string")
        
        let emptyString = ""
        XCTAssertEqual(emptyString.firstUppercased(), "")
    }
    
    //TODO: HTML encoded string test

}
