//
//  Comment.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 05/04/23.
//

import Foundation
import CoreData

@objc(Comment)
public class Comment: Thing, Votable, Created {
    
    var ups: Int = 0
    var downs: Int = 0
    var likes: Bool? = nil
    
    var created: Date = .now
    var createdUtc: Date = .now
    
    let author: String = ""
    let sendReplies: Bool = true
    let edited: Bool = false
    let isSubmitter: Bool = false
    let body: String = ""
    let bodyHtml: String = ""
    let subredditId: String = ""
    let linkId: String = ""
    let parentId: String = ""
    let distinguished: String? = nil
    let score: Int? = nil
    @Published var replies: Listing<Comment> = Listing.empty()
    
    
    required init(id: String, name: String, kind: String, data: [String : Any]) {
        
        let moc = PersistenceController.shared.container.viewContext
        guard let entityDesc = NSEntityDescription.entity(forEntityName: "Comment", in: moc)
        else {
            fatalError("Thing entity not found!")
        }
        
        super.init(entityDecription: entityDesc, id: id, name: name, kind: kind, data: data)
        
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
        subredditId = data["subreddit_id"] as! String
        linkId = data["link_id"] as! String
        parentId = data["parent_id"] as! String
        distinguished = data["distinguished"] as? String
        score = data["score"] as? Int
        
        if let repliesJson = data["replies"] as? [String : Any] {
            replies = Listing.build(from: repliesJson)
        }
        else {
            replies = Listing.empty()
        }
        
    }
    
    
    required init(entityDecription: NSEntityDescription, id: String, name: String, kind: String, data: [String : Any]) {
        fatalError("init(entityDecription:id:name:kind:data:) has not been implemented")
    }
    
    required init(entity: NSEntityDescription, insertInto: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: insertInto)
    }
    
    
}
