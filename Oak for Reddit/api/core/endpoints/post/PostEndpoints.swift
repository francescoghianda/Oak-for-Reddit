//
//  PostEndpoints.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 14/04/23.
//

import Foundation


extension Endpoint {
    
    static func postListing(order: PostListingOrder,
                            subredditName subredditPrefixedName: String = "",
                            limit: Int = 10,
                            after: String? = nil,
                            count: Int? = nil) -> Endpoint {
        
        let path = "\(subredditPrefixedName)/\(order.rawValueNoRange)"
        
        var parameters = buildParameters([
            "limit": limit,
            "after": after,
            "count": count
        ])
        
        switch order {
        case .hot:
            parameters["g"] = "GLOBAL"
        case .top(let range):
            parameters["t"] = range
        case .controversial(let range):
            parameters["t"] = range
        default:
            break
        }
        
        return Endpoint(method: .get, scopes: [.read], needsAccount: false, path: path, parameters: parameters)
        
    }
    
    static func vote(thingName: String, dir: VoteDirection) -> Endpoint {
        
        let path = "/api/vote"
        
        let parameters: [String : Any] = [
            "id": thingName,
            "dir": dir.rawValue
        ]
        
        return Endpoint(method: .post, scopes: [.vote], needsAccount: true, path: path, parameters: parameters)
    }
    
}

enum VoteDirection: Int {
    case upvote = 1
    case downvote = -1
    case unvote = 0
}
