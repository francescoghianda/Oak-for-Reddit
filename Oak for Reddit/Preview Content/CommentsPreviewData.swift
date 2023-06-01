//
//  CommentsData.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 06/05/23.
//

import Foundation
import UIKit

struct CommentsPreviewData {
    
    static var commentData: Data = {
        
        guard let asset = NSDataAsset(name: "Comment") else {
            fatalError("Missing data asset: Comment")
        }
        
        return asset.data
        
    }()
    
    static var comment: Comment = {
        guard let data = try? JSONSerialization.jsonObject(with: commentData, options: []) as? [String : Any] else {
            fatalError("Invalid data asset: Comment")
        }
        return Thing.build(from: data)
    }()
    
    static var commentListData: Data = {
        
        guard let asset = NSDataAsset(name: "CommentList") else {
            fatalError("Missing data asset: PostList")
        }
        
        return asset.data
    }()
    
    static var commentList: Listing<Comment> = {
        guard let data = try? JSONSerialization.jsonObject(with: commentListData, options: []) as? [[String : Any]] else {
            fatalError("Invalid data asset: CommentList")
        }
        
        return Listing.build(from: data[1])
    }()
    
    
    static var moreCommentsData: Data = {
        
        guard let asset = NSDataAsset(name: "MoreComments") else {
            fatalError("Missing data asset: MoreComments")
        }
        
        return asset.data
        
    }()
}
