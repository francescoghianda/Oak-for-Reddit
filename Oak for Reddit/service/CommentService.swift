//
//  CommentService.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 08/05/23.
//

import Foundation

protocol CommentService {
    
    func fetch(order: CommentsOrder, postId: String, subredditName: String) async throws -> Listing<Comment>
    func fetchChildren(order: CommentsOrder, linkId: String, childrenIds: [String]) async throws -> (comments: [Comment], mores: [More])
    
}

class NetworkCommentService: CommentService {
    
    private let api: ApiFetcher = ApiFetcher.shared
    
    func fetch(order: CommentsOrder, postId: String, subredditName: String) async throws -> Listing<Comment> {
        
        let result = try await api.fetchJsonArray(.commentListing(order: order, postId: postId, subredditName: subredditName))
        return Listing.build(from: result[1])
    }
    
    func fetchChildren(order: CommentsOrder, linkId: String, childrenIds: [String]) async throws -> (comments: [Comment], mores: [More]) {
        
        let endpoint = Endpoint.moreChildren(order: order, linkId: linkId, children: childrenIds)
        return try await ApiFetcher.shared.fetch(endpoint: endpoint, parser: Parsers.moreCommentsParser)
    }
    
    
}

class MockCommentService: CommentService {
    
    func fetch(order: CommentsOrder, postId: String, subredditName: String) async throws -> Listing<Comment> {
        try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
        return CommentsPreviewData.commentList
    }
    
    func fetchChildren(order: CommentsOrder, linkId: String, childrenIds: [String]) async throws -> (comments: [Comment], mores: [More]) {
        try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
        return ([CommentsPreviewData.comment], [])
    }
    
    
}
