//
//  PostService.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 08/05/23.
//

import Foundation

protocol PostService {
    
    func fetch(order: PostListingOrder, subredditName: String) async throws -> Listing<Post>
    func fetchMore(order: PostListingOrder, subredditName: String, after: String, count: Int) async throws -> Listing<Post>
    
}

class NetworkPostService: PostService {
    
    private let api: ApiFetcher = ApiFetcher.shared
    
    func fetch(order: PostListingOrder, subredditName: String) async throws -> Listing<Post> {
        try await api.fetchListing(.postListing(order: order, subredditName: subredditName))
    }
    
    func fetchMore(order: PostListingOrder, subredditName: String, after: String, count: Int) async throws -> Listing<Post> {
        try await api.fetchListing(.postListing(order: order, subredditName: subredditName, after: after, count: count))
    }
    
}

class MockPostService: PostService {
    
    func fetch(order: PostListingOrder, subredditName: String) async throws -> Listing<Post> {
        try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
        return PostsPreviewData.postList
    }
    
    func fetchMore(order: PostListingOrder, subredditName: String, after: String, count: Int) async throws -> Listing<Post> {
        Listing.empty()
    }
    
}
