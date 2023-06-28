//
//  CommentsModel_Tests.swift
//  Oak for Reddit Unit Tests
//
//  Created by Francesco Ghianda on 14/05/23.
//

import XCTest
@testable import Oak_for_Reddit

class CommentsModel_Tests: XCTestCase {

    class TestCommentService: CommentService {
        
        var failingService: Bool = false
        var model: CommentsModel!
        var expectation: XCTestExpectation!
        
        func fetch(order: CommentsOrder, postId: String, subredditName: String) async throws -> Listing<Comment> {
            
            if model.loading == true && model.error == nil {
                expectation.fulfill()
            }
            
            if failingService {
                throw FetchError.unexpected(error: nil)
            }
            
            return CommentsPreviewData.commentList
            
        }
        
        func fetchChildren(order: CommentsOrder, linkId: String, childrenIds: [String]) async throws -> (comments: [Comment], mores: [More]) {
            
            if failingService {
                throw FetchError.unexpected(error: nil)
            }
            
            let data = CommentsPreviewData.moreCommentsData
            
            if let result = try? Parsers.moreCommentsParser(data) {
                return result
            }
            
            throw FetchError.parser_error
            
        }
        
    }
    
    private var model:  CommentsModel!
    private var service: TestCommentService!
    
    override func setUp() {
        service = TestCommentService()
        model = CommentsModel(service: service, postId: "", subredditName: nil)
        service.model = model
    }
    
    func test_CommentsModel_load() {
        
        let serviceExpectation = expectation(description: "Service Expectation: <loading> should be set to 'true' and <error> should be set to 'nil'")
        service.expectation = serviceExpectation
        
        let completionExpectation = expectation(description: "Loading completed")
        
        model.load(sort: .new) { _ in
            completionExpectation.fulfill()
        }
        
        wait(for: [serviceExpectation, completionExpectation], timeout: 3.0)
        
        XCTAssertFalse(model.loading)
        XCTAssertNil(model.error)
        
    }
    

}
