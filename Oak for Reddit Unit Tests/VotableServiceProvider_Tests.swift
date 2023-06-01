//
//  VotableServiceProvider_Tests.swift
//  Oak for Reddit Unit Tests
//
//  Created by Francesco Ghianda on 11/05/23.
//

import XCTest
@testable import Oak_for_Reddit

class VotableServiceProvider_Tests: XCTestCase {
    
    class TestVotableService: VotableService {
        
        var failingService: Bool = false
        
        func vote(name: String, direction: VoteDirection) async throws -> Bool {
            
            if failingService {
                throw FetchError.unexpected(error: nil)
            }
            
            return true
            
        }
        
    }
    
    class TestVotable: Named, Votable, VotableServiceProvider {
        
        var votableService: VotableService
        
        var name: String
        
        var ups: Int
        var downs: Int
        var likes: Bool?
        
        init(service: VotableService, name: String = "", ups: Int = 0, downs: Int = 0, likes: Bool?) {
            self.votableService = service
            self.name = name
            self.ups = ups
            self.downs = downs
            self.likes = likes
        }
    }
    

    var service: TestVotableService!
    
    override func setUp() {
        service = TestVotableService()
    }
    
    private func voteAndWait(_ votable: TestVotable, direction: VoteDirection) {
        let completionExpect = expectation(description: "Completion expectation")
        
        votable.vote(direction: direction) { success in
            completionExpect.fulfill()
        }
        
        wait(for: [completionExpect], timeout: 3.0)
    }

    func test_VotableServiceProvider_voteNotVoted_shouldResultInVoted() {
        
        let votable = TestVotable(service: service, likes: nil)
        
        voteAndWait(votable, direction: .upvote)
        
        XCTAssertNotNil(votable.likes)
        XCTAssertTrue(votable.likes!)
        XCTAssertTrue(votable.upvoted)
        XCTAssertFalse(votable.downvoted)
        
        
        votable.likes = nil
        
        voteAndWait(votable, direction: .downvote)
        
        XCTAssertNotNil(votable.likes)
        XCTAssertFalse(votable.likes!)
        XCTAssertTrue(votable.downvoted)
        XCTAssertFalse(votable.upvoted)
        
        
        votable.likes = nil
        
        voteAndWait(votable, direction: .unvote)
        
        XCTAssertNil(votable.likes)
        XCTAssertFalse(votable.downvoted)
        XCTAssertFalse(votable.upvoted)
    }
    
    func test_VotableServiceProvider_unvoteAVoted_shouldResultInUnvoted() {
        
        let votable = TestVotable(service: service, likes: Bool.random())
        
        voteAndWait(votable, direction: .unvote)
        
        XCTAssertNil(votable.likes)
        XCTAssertFalse(votable.upvoted)
        XCTAssertFalse(votable.downvoted)
        
    }
    
    func test_VotableServiceProvider_voteSameDirection_shouldResultInUnvoted() {
        
        let votable = TestVotable(service: service, likes: true)
        
        voteAndWait(votable, direction: .upvote)
        
        XCTAssertNil(votable.likes)
        XCTAssertFalse(votable.upvoted)
        XCTAssertFalse(votable.downvoted)
        
        votable.likes = false
        
        voteAndWait(votable, direction: .downvote)
        
        XCTAssertNil(votable.likes)
        XCTAssertFalse(votable.upvoted)
        XCTAssertFalse(votable.downvoted)
    }
    
    func test_VotableServiceProvider_voteOppositeDirection_shouldInvertTheVote() {
        
        let votable = TestVotable(service: service, likes: true)
        
        voteAndWait(votable, direction: .downvote)
        
        XCTAssertNotNil(votable.likes)
        XCTAssertFalse(votable.upvoted)
        XCTAssertTrue(votable.downvoted)
        
        votable.likes = false
        
        voteAndWait(votable, direction: .upvote)
        
        XCTAssertNotNil(votable.likes)
        XCTAssertTrue(votable.upvoted)
        XCTAssertFalse(votable.downvoted)
        
    }
    
    func test_VotableServiceProvider_voteWithError_shouldNotChangeTheVote() {
        
        service.failingService = true
        
        let votable = TestVotable(service: service, likes: true)
        
        voteAndWait(votable, direction: .downvote)
        
        XCTAssertNotNil(votable.likes)
        XCTAssertTrue(votable.upvoted)
        XCTAssertFalse(votable.downvoted)
        
        votable.likes = false
        
        voteAndWait(votable, direction: .downvote)
        
        XCTAssertNotNil(votable.likes)
        XCTAssertFalse(votable.upvoted)
        XCTAssertTrue(votable.downvoted)
        
        
        votable.likes = nil
        
        voteAndWait(votable, direction: .downvote)
        
        XCTAssertNil(votable.likes)
        XCTAssertFalse(votable.upvoted)
        XCTAssertFalse(votable.downvoted)
    }
}
