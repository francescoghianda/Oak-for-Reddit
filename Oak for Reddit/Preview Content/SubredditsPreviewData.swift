//
//  SubredditsPreviewData.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 10/05/23.
//

import Foundation
import UIKit

struct SubredditsPreviewData {
    
    
    static var subredditData: Data = {
        
        guard let asset = NSDataAsset(name: "Subreddit") else {
            fatalError("Missing data asset: Subreddit")
        }
        
        return asset.data
        
    }()
    
    static var subreddit: Subreddit = {
        guard let data = try? JSONSerialization.jsonObject(with: subredditData, options: []) as? [String : Any] else {
            fatalError("Invalid data asset: Subreddit")
        }
        return Thing.build(from: data)
    }()
    
    static var subredditListData: Data = {
        
        guard let asset = NSDataAsset(name: "SubredditList") else {
            fatalError("Missing data asset: SubredditList")
        }
        
        return asset.data
    }()
    
    static var subredditList: Listing<Subreddit> = {
        guard let data = try? JSONSerialization.jsonObject(with: subredditListData, options: []) as? [String : Any] else {
            fatalError("Invalid data asset: SubredditList")
        }
        
        return Listing.build(from: data)
    }()
    
    
}
