//
//  Subreddit.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import Foundation

class Subreddit: Thing{
    
    let displayName: String
    let displayNamePrefixed: String
    let subredditName: String
    let subredditId: String
    let over18: Bool
    let primaryColor: String
    let iconImageUrl: URL?
    let bannerImageUrl: URL?
    
    required init(id: String?, name: String?, kind: String, data: [String : Any]) {
        
        displayName = data["display_name"] as! String
        displayNamePrefixed = data["display_name_prefixed"] as! String
        subredditName = data["name"] as! String
        subredditId = data["id"] as! String
        over18 = (data["over18"] as? Int ?? 0) != 0
        
        if let colorHex = data["primary_color"] as? String, colorHex != ""{
            primaryColor = colorHex
        }
        else {
            primaryColor = "#33A8FF"
        }
        
        
        iconImageUrl = Thing.extractUrl(data: data, key: "icon_img")
        bannerImageUrl = Thing.extractUrl(data: data, key: "banner_background_image")
        
        super.init(id: id, name: name, kind: kind, data: data)
    }
    
    public static let previewSubreddit: Subreddit = {
        let data: [String : Any] = [
            "display_name": "subreddit",
            "display_name_prefixed": "r/subreddit",
            "id": "000000",
            "name": "subreddit",
            "icon_img": "",
            "over18": 1,
            "primary_color": "#ef6351",
            "banner_background_image": "https://styles.redditmedia.com/t5_2qgzt/styles/bannerBackgroundImage_q87n7q1yizv41.jpg"
        ]
        return Subreddit(id: nil, name: nil, kind: "", data: data)
    }()
    
}
