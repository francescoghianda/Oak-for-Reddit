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
        
        let path = "\(subredditPrefixedName)/\(order.id)"
        
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
    
}
