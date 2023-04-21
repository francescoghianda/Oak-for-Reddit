//
//  SubredditEndpoints.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 14/04/23.
//

import Foundation

enum SubredditSearchSort: String {
    case relevance, activity
}

extension Endpoint {
    
    static func subredditListing(order: SubredditListingOrder, limit: Int = 10, after: String? = nil, count: Int? = nil) -> Endpoint {
        
        let path = "/subreddits/\(order.string)"
        
        let parameters = buildParameters([
            "limit": limit,
            "after": after,
            "count": count
        ])
        
        return Endpoint(method: .get, scopes: [.read], needsAccount: false, path: path, parameters: parameters)
    }
    
    
    static func subredditSearch(sort: SubredditSearchSort, query: String, after: String? = nil, count: UInt = 0, limit: UInt = 25) -> Endpoint {
        
        let path = "/subreddits/search"
        
        let parameters = buildParameters([
            "after": after,
            "count": count,
            "limit": min(limit, 100),
            "q": query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            "search_query_id": UUID().uuidString,
            "show_users": false,
            "sort": sort.rawValue
        ])
        
        return Endpoint(method: .get, scopes: [.read], needsAccount: false, path: path, parameters: parameters)
        
    }
    
    static func subredditsById(ids: [String]) -> Endpoint {
        
        let path = "/api/info"
        
        let parameters = [
            "id": ids.filter({ id in
                id.starts(with: ThingKind.subreddit.rawValue)
            })
        ]
        
        return Endpoint(method: .get, scopes: [.read], needsAccount: false, path: path, parameters: parameters)
        
    }
    
}
