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
    let subredditId: String
    let linkId: String
    let parentId: String
    let distinguished: String?
    let score: Int?
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
        
        let commentId = data["id"] as! String
        let commentName = data["name"] as! String
        
        super.init(id: commentId, name: commentName, kind: kind, data: data)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    /*func loadMoreReplies(sort: CommentsOrder) async {
        
        guard let more = replies.more,
              more.count > 0
        else {
            return
        }
        
        let splitted = more.children.split(at: 10)
        let toLoad = splitted.left
        //let remaining = splitted.right
        
        let parameters: [String : Any] = [
            "api_type": "json",
            "link_id": linkId,
            "sort": sort.rawValue,
            "children": toLoad.joined(separator: ","),
            "limit_children": 0
        ]
        
        let endpoint = ApiEndpoint(scope: "read", path: "/api/morechildren", method: "POST", parameters: parameters)
        
        do {
            let result = try await RedditApi.shared.fetch(endpoint: endpoint, parser: { data -> (comments: [Comment], mores: [More]) in
                
                let json = (try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any])["json"] as! [String : Any]
                
                //let errors = json["errors"]
                
                //print(String(decoding: data, as: UTF8.self))
                
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
            })
            
            let newComments = result.comments
            let newMores = result.mores
            
            
            let newReplies = replies.children + buildCommentsTree(from: newComments, mores: newMores, parentId: name!)
            
            let newIds = newComments.map { comment in
                comment.thingId
            }
            
            let remaining = replies.more?.filter({ id in
                !newIds.contains(id)
            })
            
            let remainingMore: More? = {
                guard let remaining = remaining
                else {
                    return nil
                }
                return More(children: remaining,
                            name: replies.more?.name,
                            id: replies.more?.id,
                            count: remaining.count,
                            depth: replies.more?.depth,
                            parentId: replies.more?.parentId)
            }()
            
            //print("\(replies.more?.count) - \(result.count) = \(remaining?.count)")
            
            //print("Requested: \(toLoad) (\(toLoad.count))")
            //print("Received: \(newIds) (\(newIds.count)")
            
            self.replies = Listing(before: self.replies.before, after: self.replies.after, children: newReplies, more: remainingMore)
            
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    private func buildCommentsTree(from comments: [Comment], mores: [More], parentId: String) -> [Comment] {
        
        let root = comments.filter { comment in
            comment.parentId == parentId
        }
        
        for comment in root {
            
            let children = buildCommentsTree(from: comments, mores: mores, parentId: comment.name!)
            let more = mores.first { more in
                more.parentId == comment.name
            }
            
            comment.replies = Listing(before: nil, after: nil, children: children, more: more)
            
        }
        
        return root
    }*/
    
    
}
