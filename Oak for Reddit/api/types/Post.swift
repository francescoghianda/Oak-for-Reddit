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
    
    var created: Date
    var createdUtc: Date
    
    let author: String
    let hidden: Bool
    let isSelf: Bool
    let locked: Bool
    let numComments: Int
    let over18: Bool
    let score: Int
    let selfText: String
    let subreddit: String
    let subredditId: String
    let thumbnail: String
    let thumbnailUrl: URL?
    let title: String
    let permalink: String
    let url: String
    let edited: TimeInterval?
    let stickied: Bool
    
    required init(id: String?, name: String?, kind: String, data: [String : Any]) {
        
        ups = data["ups"] as! Int
        downs = data["downs"] as! Int
        likes = (data["likes"] as? Int ?? 0) != 0
        
        let createdTI = data["created"] as! TimeInterval
        created = Date(timeIntervalSince1970: createdTI)
        
        let createdUtcTI = data["created_utc"] as! TimeInterval
        createdUtc = Date(timeIntervalSince1970: createdUtcTI)

        author = data["author"] as! String
        hidden = (data["hidden"] as? Int ?? 0) != 0
        isSelf = (data["is_self"] as? Int ?? 0) != 0
        locked = (data["locked"] as? Int ?? 0) != 0
        numComments = data["num_comments"] as! Int
        over18 = (data["over_18"] as? Int ?? 0) != 0
        score = data["score"] as! Int
        selfText = data["selftext"] as! String
        subreddit = data["subreddit"] as! String
        subredditId = data["subreddit_id"] as! String
        thumbnail = data["thumbnail"] as! String
        thumbnailUrl = Thing.extractUrl(data: data, key: "thumbnail")
        
        title = Thing.extractHtmlEcodedString(data: data, key: "title")!
        
        permalink = data["permalink"] as! String
        url = data["url"] as! String
        edited = nil
        stickied = (data["stickied"] as? Int ?? 0) != 0
        
        /*if let media = data["media"]{
            print("media: \(media)")
        }*/
        
        print("url: \(url) - thumbnail: \(thumbnail)")
        
        
        super.init(id: id, name: name, kind: kind, data: data)
    }

}

extension Post {
    
    var timeSiceCreation: TimeInterval {
        Date.now.timeIntervalSince(created)
    }
    
    public func formatCreationTime(maxDays: Int = 3, dateFormatter: DateFormatter) -> String {
        
        let seconds = self.timeSiceCreation
        let mins = Int(seconds / 60)
        let hours = Int(mins / 60)
        let days = Int(hours / 24)
        
        if (seconds < 60){
            return "\(seconds)s"
        }
        
        if (mins < 60) {
            return "\(mins)m"
        }
        
        if (hours < 24) {
            return "\(hours)h"
        }

        if (days <= maxDays) {
            return "\(days)g"
        }
        
        return dateFormatter.string(from: self.created)
    }
    
    /*public func isImageUrl() -> Bool {
        
    }*/
}
