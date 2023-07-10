//
//  Listing_Tests.swift
//  Oak for Reddit Unit Tests
//
//  Created by Francesco Ghianda on 04/07/23.
//

import XCTest
@testable import Oak_for_Reddit

class Listing_Tests: XCTestCase {
    
    func test_EmptyListing() throws {
        
        let listing = Listing.empty()
        
        XCTAssertEqual(listing.count, 0)
        XCTAssertFalse(listing.hasThingsAfter)
        XCTAssertFalse(listing.hasThingsBefore)
        
    }

    func test_ListingBuildFromJson() throws {
        
        let json = """
            {
                "kind": "Listing",
                "data": {
                    "after": "aaaaa",
                    "children": [
                        {
                            "kind": "TestThing",
                            "data": {
                                "name": "test_thing",
                                "id": "00000"
                            }
                        },
                        {
                            "kind": "TestThing",
                            "data": {
                                "name": "test_thing",
                                "id": "00001"
                            }
                        }
                    ]
                }
            }

        """
        
        if let jsonDict = try? JSONSerialization.jsonObject(with: json.data(using: String.Encoding.utf8)!, options: []) as? [String : Any] {
            
            let listing = Listing.build(from: jsonDict)
            
            XCTAssertEqual(listing.count, 2)
            XCTAssertTrue(listing.hasThingsAfter)
            XCTAssertFalse(listing.hasThingsBefore)
            XCTAssertEqual(listing[0].thingId, "00000")
            XCTAssertEqual(listing[0].name, "test_thing")
            XCTAssertEqual(listing[0].kind, "TestThing")
            XCTAssertEqual(listing[1].thingId, "00001")
            XCTAssertEqual(listing[1].name, "test_thing")
            XCTAssertEqual(listing[1].kind, "TestThing")
            
            
        } else {
            XCTFail("Error in json data")
        }
        
        
    }
    
    func test_JoinTwoListing() throws {
        
        let json1 = """
            {
                "kind": "Listing",
                "data": {
                    "after": "aaaaa",
                    "before": "bbbbb",
                    "children": [
                        {
                            "kind": "TestThing",
                            "data": {
                                "name": "test_thing",
                                "id": "00000"
                            }
                        },
                        {
                            "kind": "TestThing",
                            "data": {
                                "name": "test_thing",
                                "id": "00001"
                            }
                        }
                    ]
                }
            }

        """
        
        let json2 = """
            {
                "kind": "Listing",
                "data": {
                    "after": "ccccc",
                    "before": "ddddd",
                    "children": [
                        {
                            "kind": "TestThing",
                            "data": {
                                "name": "test_thing",
                                "id": "00000"
                            }
                        },
                        {
                            "kind": "TestThing",
                            "data": {
                                "name": "test_thing",
                                "id": "00001"
                            }
                        }
                    ]
                }
            }

        """
        
        if let jsonDict1 = try? JSONSerialization.jsonObject(with: json1.data(using: String.Encoding.utf8)!, options: []) as? [String : Any],
            let jsonDict2 = try? JSONSerialization.jsonObject(with: json2.data(using: String.Encoding.utf8)!, options: []) as? [String : Any]{
            
            let listing1 = Listing.build(from: jsonDict1)
            let listing2 = Listing.build(from: jsonDict2)
            
            XCTAssertEqual(listing1.count, 2)
            XCTAssertEqual(listing2.count, 2)
            
            XCTAssertEqual(listing1.after, "aaaaa")
            XCTAssertEqual(listing1.before, "bbbbb")
            XCTAssertEqual(listing2.after, "ccccc")
            XCTAssertEqual(listing2.before, "ddddd")
            
            let listing3 = listing1 ++ listing2
            
            XCTAssertEqual(listing3.count, 4)
            XCTAssertEqual(listing3.before, "bbbbb")
            XCTAssertEqual(listing3.after, "ccccc")
            
        } else {
            
            XCTFail("Error in json data")
        }
        
        
    }

}
