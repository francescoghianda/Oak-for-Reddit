//
//  CommentEndpoints.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 14/04/23.
//

import Foundation

extension Endpoint {
    
    static func commentListing(order: CommentsOrder,
                               postId: String,
                               subredditName subredditPrefixedName: String = "",
                               limit: Int = 50) -> Endpoint {
        
        let path = "\(subredditPrefixedName)/comments/\(postId)"
        
        let parameters: ParameterDictionary = [
            "limit": limit,
            "sort": order.rawValue
        ]
        
        return Endpoint(method: .get, scopes: [.read], needsAccount: false, path: path, parameters: parameters)
    }
    
    static func moreChildren(order: CommentsOrder, linkId: String, children: [String]) -> Endpoint {
        
        let path = "/api/morechildren"
        
        let parameters: ParameterDictionary = [
            "api_type": "json",
            "link_id": linkId,
            "sort": order.rawValue,
            "children": children.joined(separator: ","),
            "limit_children": 0
        ]
        
        return Endpoint(method: .post, scopes: [.read], needsAccount: false, path: path, parameters: parameters)
    }
    
}
