//
//  Votable_Tests.swift
//  Oak for Reddit Unit Tests
//
//  Created by Francesco Ghianda on 10/05/23.
//

import XCTest
@testable import Oak_for_Reddit

class Votable_Tests: XCTestCase {

    class VotableTest: Votable {
        var ups: Int
        var downs: Int
        var likes: Bool?
        
        init(ups: Int, downs: Int, likes: Bool?) {
            self.ups = ups
            self.downs = downs
            self.likes = likes
        }
    }
    
    func test_Votable_likesEqualTrue() {
        
        let votable = VotableTest(ups: 0, downs: 0, likes: true)
        
        XCTAssertTrue(votable.upvoted)
        XCTAssertFalse(votable.downvoted)
    }
    
    func test_Votable_likesEqualFalse() {
        
        let votable = VotableTest(ups: 0, downs: 0, likes: false)
        
        XCTAssertFalse(votable.upvoted)
        XCTAssertTrue(votable.downvoted)
    }
    
    func test_Votable_likesEqualNil() {
        
        let votable = VotableTest(ups: 0, downs: 0, likes: nil)
        
        XCTAssertFalse(votable.upvoted)
        XCTAssertFalse(votable.downvoted)
    }

}
