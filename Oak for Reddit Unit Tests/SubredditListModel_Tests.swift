//
//  SubredditListModel_Tests.swift
//  Oak for Reddit Unit Tests
//
//  Created by Francesco Ghianda on 12/05/23.
//

import XCTest
@testable import Oak_for_Reddit

class SubredditListModel_Tests: XCTestCase {

    class TestSubredditService: SubredditService {
        
        var model: SubrettitListModel!
        var expectation: XCTestExpectation!
        var failingService: Bool = false
        
        func search(sort: SubredditSearchSort, query: String) async throws -> Listing<Subreddit> {
            Listing.empty()
        }
        
        func fetch(order: SubredditListingOrder) async throws -> Listing<Subreddit> {
            
            if model.loading && model.error == nil {
                expectation.fulfill()
            }
            
            if failingService {
                throw FetchError.unexpected(error: nil)
            }
            
            return SubredditsPreviewData.subredditList
        }
        
        func fetchMore(order: SubredditListingOrder, after: String, count: Int) async throws -> Listing<Subreddit> {
            
            if model.loadingMore && model.errorLoadingMore == nil {
                expectation.fulfill()
            }
            
            if failingService {
                throw FetchError.unexpected(error: nil)
            }
            
            return SubredditsPreviewData.subredditList
        }
        
    }
    
    
    private var model:  SubrettitListModel!
    private var service: TestSubredditService!
    
    override func setUp() {
        service = TestSubredditService()
        model = SubrettitListModel(service: service)
        service.model = model
    }
    

    func test_SubredditListModel_fetch_shouldSetLoadingAndErrorCorreclty() {
        
        let serviceExpectation = expectation(description: "Service Expectation: <loading> should be set to 'true' and <error> should be set to 'nil'")
        service.expectation = serviceExpectation
        
        let completionExpectation = expectation(description: "Loading completed")
        
        model.load(order: .new) { _ in
            completionExpectation.fulfill()
        }
        
        wait(for: [serviceExpectation, completionExpectation], timeout: 3.0)
        
        XCTAssertFalse(model.loading)
        XCTAssertNil(model.error)
        
    }
    
    func test_SubredditListModel_fetchWithError_shouldSetLoadingAndErrorCorreclty() {
        
        service.failingService = true
        
        let serviceExpectation = expectation(description: "<loading> should be set to 'true' and <error> should be set to 'nil'")
        service.expectation = serviceExpectation
        
        let completionExpectation = expectation(description: "Loading completed")
        
        model.load(order: .new) { _ in
            completionExpectation.fulfill()
        }
        
        wait(for: [serviceExpectation, completionExpectation], timeout: 3.0)
        
        XCTAssertFalse(model.loading)
        XCTAssertNotNil(model.error)
        
    }
    
    func test_SubredditListModel_fetchMore_shouldSetLoadingAndErrorCorreclty() {
        
        let serviceExpectation = expectation(description: "Service Expectation: <loadingMore> should be set to 'true' and <loadingMoreError> should be set to 'nil'")
        service.expectation = serviceExpectation
        
        model.subreddits = SubredditsPreviewData.subredditList
        
        let completionExpectation = expectation(description: "Loading completed")
        
        model.loadMore(order: .new) { _ in
            completionExpectation.fulfill()
        }
        
        wait(for: [serviceExpectation, completionExpectation], timeout: 3.0)
        
        XCTAssertFalse(model.loadingMore)
        XCTAssertNil(model.errorLoadingMore)        
    }
    
    func test_SubredditListModel_fetchMoreWithError_shouldSetLoadingAndErrorCorreclty() {
        
        service.failingService = true
        
        let serviceExpectation = expectation(description: "Service Expectation: <loadingMore> should be set to 'true' and <loadingMoreError> should be set to 'nil'")
        service.expectation = serviceExpectation
        
        let completionExpectation = expectation(description: "Loading completed")
        
        model.subreddits = Listing(before: nil, after: "after", children: [], more: nil)
        
        model.loadMore(order: .new) { _ in
            completionExpectation.fulfill()
        }
        
        wait(for: [serviceExpectation, completionExpectation], timeout: 3.0)
        
        XCTAssertFalse(model.loadingMore)
        XCTAssertNotNil(model.errorLoadingMore)
        
    }
    

}
