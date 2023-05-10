//
//  URLExtensions_Test.swift
//  Oak for Reddit Unit Tests
//
//  Created by Francesco Ghianda on 08/05/23.
//

import XCTest
@testable import Oak_for_Reddit


class URLExtensions_Tests: XCTestCase {
    
    func test_URLExtensions_getQueryParameter_shouldReturnTheParameter() {
            
        let param1 = UUID().uuidString
        let param2 = UUID().uuidString
        
        if let url = URL(string: "http://localhost:8080?param1=\(param1)&param2=\(param2)") {
            
            let readParam1 = url.getQueryParameter("param1")
            let readParam2 = url.getQueryParameter("param2")
            
            XCTAssertEqual(readParam1, param1)
            XCTAssertEqual(readParam2, param2)
            
        }
        else {
            XCTFail("Invalid test URL")
        }
            
    }
    
    func test_URLExtensions_getQueryParameter_shouldReturnNil() {
        
        if let url = URL(string: "http://localhost:8080") {
            
            let readParam1 = url.getQueryParameter("param1")
            let readParam2 = url.getQueryParameter("param2")
            
            XCTAssertNil(readParam1)
            XCTAssertNil(readParam2)
            
        }
        else {
            XCTFail("Invalid test URL")
        }
            
    }
    
}
