//
//  PostListModel_Tests.swift
//  Oak for Reddit Unit Tests
//
//  Created by Francesco Ghianda on 11/05/23.
//

import XCTest
@testable import Oak_for_Reddit

class PostListModel_Tests: XCTestCase {
    
    class TestPostService: PostService {
        
        var model: PostListModel!
        var expectation: XCTestExpectation!
        var failingService: Bool = false
        
        func fetch(order: PostListingOrder, subredditName: String) async throws -> Listing<Post> {
            
            if model.loading && model.error == nil {
                expectation.fulfill()
            }
            
            if failingService {
                throw FetchError.unexpected(error: nil)
            }
            
            return PostsPreviewData.postList
        }
        
        func fetchMore(order: PostListingOrder, subredditName: String, after: String, count: Int) async throws -> Listing<Post> {
            
            if model.loadingMore && model.loadingMoreError == nil {
                expectation.fulfill()
            }
            
            if failingService {
                throw FetchError.unexpected(error: nil)
            }
            
            return PostsPreviewData.postList
        }
        
        func vote(name: String, direction: VoteDirection) async throws -> Bool {
            return true
        }
        
    }
    
    
    private var model:  PostListModel!
    private var service: TestPostService!
    
    override func setUp() {
        service = TestPostService()
        model = PostListModel(service: service, subredditNamePrefixed: nil)
        service.model = model
    }
    

    func test_PostListModel_fetch_shouldSetLoadingAndErrorCorreclty() {
        
        let serviceExpectation = expectation(description: "Service Expectation: <loading> should be set to 'true' and <error> should be set to 'nil'")
        service.expectation = serviceExpectation
        
        let completionExpectation = expectation(description: "Loading completed")
        
        model.load(order: .best) { posts in
            completionExpectation.fulfill()
        }
        
        wait(for: [serviceExpectation, completionExpectation], timeout: 3.0)
        
        XCTAssertFalse(model.loading)
        XCTAssertNil(model.error)
        
    }
    
    func test_PostListModel_fetchWithError_shouldSetLoadingAndErrorCorreclty() {
        
        service.failingService = true
        
        let serviceExpectation = expectation(description: "<loading> should be set to 'true' and <error> should be set to 'nil'")
        service.expectation = serviceExpectation
        
        let completionExpectation = expectation(description: "Loading completed")
        
        model.load(order: .best) { _ in
            completionExpectation.fulfill()
        }
        
        wait(for: [serviceExpectation, completionExpectation], timeout: 3.0)
        
        XCTAssertFalse(model.loading)
        XCTAssertNotNil(model.error)
        
    }
    
    func test_PostListModel_fetchMore_shouldSetLoadingAndErrorCorreclty() {
        
        let serviceExpectation = expectation(description: "Service Expectation: <loadingMore> should be set to 'true' and <loadingMoreError> should be set to 'nil'")
        service.expectation = serviceExpectation
        
        model.posts = PostsPreviewData.postList
        let initialPostCount = model.posts.count
        var newPostsCount = 0
        
        let completionExpectation = expectation(description: "Loading completed")
        
        model.loadMore(order: .best) { newPosts in
            newPostsCount = newPosts?.count ?? 0
            completionExpectation.fulfill()
        }
        
        wait(for: [serviceExpectation, completionExpectation], timeout: 3.0)
        
        XCTAssertFalse(model.loadingMore)
        XCTAssertNil(model.loadingMoreError)
        XCTAssertEqual(model.posts.count, initialPostCount + newPostsCount)
        
    }
    
    func test_PostListModel_fetchMoreWithError_shouldSetLoadingAndErrorCorreclty() {
        
        service.failingService = true
        
        let serviceExpectation = expectation(description: "Service Expectation: <loadingMore> should be set to 'true' and <loadingMoreError> should be set to 'nil'")
        service.expectation = serviceExpectation
        
        let completionExpectation = expectation(description: "Loading completed")
        
        model.loadMore(order: .best) { newPosts in
            completionExpectation.fulfill()
        }
        
        wait(for: [serviceExpectation, completionExpectation], timeout: 3.0)
        
        XCTAssertFalse(model.loadingMore)
        XCTAssertNotNil(model.loadingMoreError)
        
    }

}
