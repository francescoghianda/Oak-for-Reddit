//
//  Subreddit.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import Foundation

class Subreddit: Thing {
    
    let displayName: String
    let subredditName: String
    let subredditId: String
    let iconImageUrl: URL?
    
    required init(id: String?, name: String?, kind: String, data: [String : Any]) {
        
        displayName = data["display_name"] as! String
        subredditName = data["name"] as! String
        subredditId = data["id"] as! String
        
        if let iconImagePath = data["icon_img"] as? String {
            iconImageUrl = URL(string: iconImagePath)
        }
        else{
            iconImageUrl = nil
        }
        
        super.init(id: id, name: name, kind: kind, data: data)
    }
    
    public static let previewSubreddit: Subreddit = {
        let data = [
            "display_name": "preview subreddit",
            "name": "preview",
            "icon_img": "https://www.iconsdb.com/icons/preview/royal-azure-blue/test-tube-xxl.png"
        ]
        return Subreddit(id: nil, name: nil, kind: "", data: data)
    }()
    
}
