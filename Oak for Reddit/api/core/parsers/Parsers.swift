//
//  Parsers.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 14/04/23.
//

import Foundation

struct Parsers {
    
    static let identity: RedditApi.Parser<Data> = { data in
        data
    }
    
    static func jsonParser<T>(_ data: Data) throws -> T? {
        return try JSONSerialization.jsonObject(with: data, options: []) as? T
    }
    
    static func listingParser<T>(_ data: Data) throws -> Listing<T> {
        
        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
            return Listing.build(from: json)
        }
        
        return Listing.empty()
    }
    
    static let moreCommentsParser: RedditApi.Parser<(comments: [Comment], mores: [More])> = { data in
        
        let json = (try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any])["json"] as! [String : Any]
        
        //let errors = json["errors"]
        
        let jsonData = json["data"] as! [String : Any]
        let things = jsonData["things"] as! [[String : Any]]
        
        let commentsData = things.filter { thing in
            thing["kind"] as! String == "t1"
        }
        
        let moresData = things.compactMap { thing -> [String : Any]? in
            if thing["kind"] as! String == "more" {
                return thing["data"] as? [String : Any]
            }
            return nil
        }
                        
        let comments: [Comment] = commentsData.map { comment in
            Thing.build(from: comment)
        }
        
        let mores = moresData.map { more in
            More.build(from: more)
        }
        
        return (comments: comments, mores: mores)
    }
    
    
    
}
