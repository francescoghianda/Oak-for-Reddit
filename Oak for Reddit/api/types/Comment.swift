//
//  Comment.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 05/04/23.
//

import Foundation


class Comment: Thing, Votable, Created, ObservableObject {
    
    var ups: Int
    var downs: Int
    var likes: Bool?
    
    var created: Date
    var createdUtc: Date
    
    let author: String
    let sendReplies: Bool
    let edited: Bool
    let isSubmitter: Bool
    let body: String
    let bodyHtml: String
    @Published var replies: Listing<Comment>
    
    
    required init(id: String?, name: String?, kind: String, data: [String : Any]) {
        
        ups = Thing.get("ups", from: data, defaultValue: 0)
        downs = Thing.get("downs", from: data, defaultValue: 0)
        likes = Thing.getBool("likes", from: data)
        
        let createdTI = data["created"] as! TimeInterval
        created = Date(timeIntervalSince1970: createdTI)
        
        let createdUtcTI = data["created_utc"] as! TimeInterval
        createdUtc = Date(timeIntervalSince1970: createdUtcTI)
        
        author = data["author"] as! String
        sendReplies = (data["send_replies"] as? Int ?? 0) != 0
        edited = (data["edited"] as? Int ?? 0) != 0
        isSubmitter = (data["is_submitter"] as? Int ?? 0) != 0
        body = data["body"] as! String
        bodyHtml = Thing.getHtmlEcodedString(data: data, key: "body_html") ?? ""
        
        if let repliesJson = data["replies"] as? [String : Any] {
            replies = Listing.build(from: repliesJson)
        }
        else {
            replies = Listing.empty()
        }
        
        super.init(id: id, name: name, kind: kind, data: data)
    }
    
    func loadMoreReplies() async {
        
        if let more = replies.more {
            
        }
        
    }
    
    
}
