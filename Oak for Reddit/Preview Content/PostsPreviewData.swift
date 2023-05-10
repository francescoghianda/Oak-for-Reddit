//
//  PostsData.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 06/05/23.
//

import Foundation
import UIKit

struct PostsPreviewData {
    
    
    static var postData: Data = {
        
        guard let asset = NSDataAsset(name: "Post") else {
            fatalError("Missing data asset: Post")
        }
        
        return asset.data
        
    }()
    
    static var post: Post = {
        guard let data = try? JSONSerialization.jsonObject(with: postData, options: []) as? [String : Any] else {
            fatalError("Invalid data asset: Post")
        }
        return Thing.build(from: data)
    }()
    
    static var postListData: Data = {
        
        guard let asset = NSDataAsset(name: "PostList") else {
            fatalError("Missing data asset: PostList")
        }
        
        return asset.data
    }()
    
    static var postList: Listing<Post> = {
        guard let data = try? JSONSerialization.jsonObject(with: postListData, options: []) as? [String : Any] else {
            fatalError("Invalid data asset: PostList")
        }
        
        return Listing.build(from: data)
    }()
    
    
}
