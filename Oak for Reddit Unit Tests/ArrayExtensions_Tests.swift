//
//  ArrayExtensions_Tests.swift
//  Oak for Reddit Unit Tests
//
//  Created by Francesco Ghianda on 09/05/23.
//

import XCTest
@testable import Oak_for_Reddit

class ArrayExtensions_Tests: XCTestCase {

    
    func test_ArrayExtensions_split() {
        
        let array = [0, 1, 2, 3, 4, 5, 6]
        
        var splitted = array.split(at: 3)
        
        XCTAssertEqual(splitted.left.count, 3)
        XCTAssertEqual(splitted.right.count, 4)
        
        splitted = array.split(at: 0)
        
        XCTAssertEqual(splitted.left.count, 0)
        XCTAssertEqual(splitted.right.count, array.count)
        
        splitted = array.split(at: array.count)
        
        XCTAssertEqual(splitted.left.count, array.count)
        XCTAssertEqual(splitted.right.count, 0)
        
        splitted = array.split(at: array.count + 1)
        
        XCTAssertEqual(splitted.left.count, array.count)
        XCTAssertEqual(splitted.right.count, 0)
    }

}
