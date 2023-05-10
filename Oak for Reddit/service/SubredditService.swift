//
//  SubredditServiceProtocol.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 08/05/23.
//

import Foundation

protocol SubredditService {
    
    func search(sort: SubredditSearchSort, query: String) async throws -> Listing<Subreddit>
    func fetch(order: SubredditListingOrder) async throws -> Listing<Subreddit>
    func fetchMore(order: SubredditListingOrder, after: String, count: Int) async throws -> Listing<Subreddit>
    
}

class NetworkSubredditService: SubredditService {
    
    private let api: ApiFetcher = ApiFetcher.shared
    
    func fetch(order: SubredditListingOrder) async throws -> Listing<Subreddit> {
        try await api.fetchListing(.subredditListing(order: order))
    }
    
    func fetchMore(order: SubredditListingOrder, after: String, count: Int) async throws -> Listing<Subreddit> {
        try await api.fetchListing(.subredditListing(order: order, after: after, count: count))
    }
    
    func search(sort: SubredditSearchSort, query: String) async throws -> Listing<Subreddit> {
        try await api.fetchListing(.subredditSearch(sort: sort, query: query))
    }
    
}


class MockSubredditService: SubredditService {
    
    func search(sort: SubredditSearchSort, query: String) async throws -> Listing<Subreddit> {
        try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
        return Listing.empty()
    }
    
    func fetch(order: SubredditListingOrder) async throws -> Listing<Subreddit> {
        try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
        return SubredditsPreviewData.subredditList
    }
    
    func fetchMore(order: SubredditListingOrder, after: String, count: Int) async throws -> Listing<Subreddit> {
        try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
        return Listing.empty()
    }
    
}
