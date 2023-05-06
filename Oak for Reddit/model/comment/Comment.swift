//
//  Comment.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 05/04/23.
//

import Foundation


class Comment: Thing, Votable, Created {
    
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
    let subredditId: String
    let linkId: String
    let parentId: String
    let distinguished: String?
    let score: Int?
    @Published var replies: Listing<Comment>
    
    override func isEqual(to other: Thing) -> Bool {
        guard let other = other as? Comment else {
            return false
        }
        
        return super.isEqual(to: other) && replies == other.replies
    }
    
    required init(id: String, name: String, kind: String, data: [String : Any]) {
        
        ups = data.get("ups", defaultValue: 0)
        downs = data.get("downs", defaultValue: 0)
        likes = data.getBool("likes")
        
        created = data.getDate("created")
        createdUtc = data.getDate("created_utc")
        
        author = data.get("author")
        sendReplies = data.getBool("send_replies")
        edited = data.getBool("edited")
        isSubmitter = data.getBool("is_submitter")
        body = data.get("body")
        bodyHtml = data.getHtmlEcodedString("body_html") ?? ""
        subredditId = data.get("subreddit_id")
        linkId = data.get("link_id")
        parentId = data.get("parent_id")
        distinguished = data.get("distinguished")
        score = data.get("score")
        
        if let repliesJson = data.getDictionary("replies") {
            replies = Listing.build(from: repliesJson)
        }
        else {
            replies = Listing.empty()
        }
        
        super.init(id: id, name: name, kind: kind, data: data)
    }
    
}
