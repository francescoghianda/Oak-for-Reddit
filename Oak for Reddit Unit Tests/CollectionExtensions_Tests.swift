//
//  CollectionExtensions_Tests.swift
//  Oak for Reddit Unit Tests
//
//  Created by Francesco Ghianda on 08/05/23.
//

import XCTest
@testable import Oak_for_Reddit

class CollectionExtensions_Tests: XCTestCase {
    
    func test_CollectionExtension_safeSubscript_shouldReturnTheElement() {
        
        let element1 = "element1"
        let element2 = "element2"
        let element3 = "element3"
        
        let collection = [element1, element2, element3]
        
        XCTAssertEqual(element1, collection[safe: 0])
        XCTAssertEqual(element2, collection[safe: 1])
        XCTAssertEqual(element3, collection[safe: 2])
        
    }
    
    func test_CollectionExtension_safeSubscript_shouldReturnNil() {
        
        
        let collection: [Any] = []
        
        XCTAssertNil(collection[safe: -1])
        XCTAssertNil(collection[safe: 0])
        XCTAssertNil(collection[safe: 1])
        
    }
    
}
