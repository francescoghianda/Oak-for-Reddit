//
//  Post.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 21/03/23.
//

import Foundation

class Post: Thing, Votable, Created {
    
    var ups: Int
    var downs: Int
    var likes: Bool?
    
    var created: TimeInterval
    var created_utc: TimeInterval
    
    required init(id: String?, name: String?, kind: String, data: [String : Any]) {
        
        ups = data["ups"] as! Int
        downs = data["downs"] as! Int
        likes = (data["over18"] as? Int ?? 0) != 0
        
        created = data["created"] as! TimeInterval
        created_utc = data["created_utc"] as! TimeInterval
        
        
        
        super.init(id: id, name: name, kind: kind, data: data)
    }
    
    
}
