//
//  DictionaryExtensions_Tests.swift
//  Oak for Reddit Unit Tests
//
//  Created by Francesco Ghianda on 09/05/23.
//

import XCTest
@testable import Oak_for_Reddit

class DictionaryExtensions_Tests: XCTestCase {

    
    func test_DictionaryExtensions_get() {
        
        let dict: [String : Any] = [
            "prop1": "value1",
            "prop2": 34,
            "prop3": 27.10
        ]
        
        let value1: String = dict.get("prop1")
        XCTAssertEqual("value1", value1)
        
        let value2: String? = dict.get("prop2")
        XCTAssertNil(value2)
        
        let value3: Int = dict.get("prop2")
        XCTAssertEqual(34, value3)
        
        let value4: Double = dict.get("prop3")
        XCTAssertEqual(27.10, value4)
        
        let value5: String? = dict.get("key_that_does_not_exist")
        XCTAssertNil(value5)
        
        let value6: String = dict.get("key_that_does_not_exist", defaultValue: "defaultValue")
        XCTAssertNotNil(value6)
        XCTAssertEqual(value6, "defaultValue")
    }
    
    func test_DictionaryExtensions_getBool() {
        
        let dict: [String : Any] = [
            "prop1": 0,
            "prop2": 1,
            "prop3": 45,
            "prop4": "string"
        ]
        
        let value1: Bool = dict.getBool("prop1")
        XCTAssertEqual(false, value1)
        
        let value2: Bool? = dict.getBool("prop1")
        XCTAssertNotNil(value2)
        XCTAssertEqual(false, value2!)
        
        let value3: Bool = dict.getBool("prop2")
        XCTAssertEqual(true, value3)
        
        let value4: Bool? = dict.getBool("prop2")
        XCTAssertNotNil(value4)
        XCTAssertEqual(true, value4!)
        
        let value5: Bool? = dict.getBool("prop3")
        XCTAssertNotNil(value5)
        XCTAssertEqual(true, value5!)
        
        let value6: Bool? = dict.getBool("prop4")
        XCTAssertNil(value6)
        
        let value7: Bool? = dict.getBool("prgp1")
        XCTAssertNil(value7)
    }
    
    func test_DictionaryExtensions_getDate() {
        let date: Date = .now
        
        let dict: [String : Any] = [
            "date": date.timeIntervalSince1970
        ]
        
        let value: Date? = dict.getDate("date")
        XCTAssertNotNil(value)
        XCTAssertEqual(date.description, value?.description)
    }
    
    func test_DictionaryExtensions_getDictionary() {
        let dict: [String : Any] = [
            "subdict": [
                "prop1": "value1",
                "prop2": 2
            ],
            "otherkey": "othervalue"
        ]
        
        let subdict = dict.getDictionary("subdict")
        XCTAssertNotNil(subdict)
        XCTAssertEqual(subdict!.count, 2)
        XCTAssertEqual(subdict!["prop1"] as! String, "value1")
        XCTAssertEqual(subdict!["prop2"] as! Int, 2)
        
        let nilVal = dict.getDictionary("key_that_does_not_exist")
        XCTAssertNil(nilVal)
    }
    
    func test_DictionaryExtensions_getDictionaryArray() {
        let dict: [String : Any] = [
            "arrayOfDict": [["prop1": "value1", "prop2": 2], ["prop1": 1, "prop2": "value2"]],
            "otherprop": "othervalue"
        ]
        
        let array = dict.getDictionaryArray("arrayOfDict")
        XCTAssertNotNil(array)
        XCTAssertEqual(array!.count, 2)
        
        let dict1 = array![0]
        let dict2 = array![1]
        XCTAssertEqual(dict1.count, 2)
        XCTAssertEqual(dict2.count, 2)
        XCTAssertEqual(dict1["prop1"] as! String, "value1")
        XCTAssertEqual(dict2["prop1"] as! Int, 1)
        XCTAssertEqual(dict1["prop2"] as! Int, 2)
        XCTAssertEqual(dict2["prop2"] as! String, "value2")
        
        let nilVal = dict.getDictionaryArray("key_that_does_not_exist")
        XCTAssertNil(nilVal)
    }
    
    func test_DictionaryExtensions_getUrl() {
        
        let dict: [String : Any] = [
            "url": "https://localhost:8080",
            "otherprop": 2
        ]
        
        let url = dict.getUrl("url")
        XCTAssertNotNil(url)
        XCTAssertEqual(url!.description, "https://localhost:8080")
        
        let nilVal = dict.getUrl("key_that_does_not_exist")
        XCTAssertNil(nilVal)
        
    }

    func test_DictionaryExtensions_percentEncoded() {
        
        let dictionary: [String : Any] = [
            "prop1": "value1",
            "prop2": 2,
            "prop 3": "value 3",
            "prop4": false
        ]
        
        if let data = dictionary.percentEncoded() {
            let returnedPercentEncoded = String(decoding: data, as: UTF8.self)
            
            let properties = ["prop1=value1", "prop2=2", "prop%203=value%203", "prop4=false"]
            let splitted = returnedPercentEncoded.split(separator: "&").map { String($0) }
            
            XCTAssertEqual(splitted.count, dictionary.count)
            
            for property in properties {
                XCTAssertTrue(splitted.contains(property))
            }
            
        }
        else {
            XCTFail()
        }
    }
    
    

}
