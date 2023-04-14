//
//  SubredditEndpoints.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 14/04/23.
//

import Foundation

extension Endpoint {
    
    static func subredditListing(order: SubredditListingOrder, limit: Int = 10, after: String? = nil, count: Int? = nil) -> Endpoint {
        
        let path = "/subreddits/\(order.id)"
        
        let parameters = buildParameters([
            "limit": limit,
            "after": after,
            "count": count
        ])
        
        return Endpoint(method: .get, scopes: [.read], needsAccount: false, path: path, parameters: parameters)
    }
    
}
