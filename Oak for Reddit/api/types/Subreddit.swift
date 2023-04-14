//
//  Subreddit.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import Foundation
import CoreData

class Subreddit: Thing{
    
    enum CodingKeys : String, CodingKey {
        case displayName = "display_name"
        case displayNamePrefixed = "display_name_prefixed"
        case subredditName = "subreddit_name"
        case subredditId = "subreddit_id"
        case over18 = "over_18"
        case primaryColor = "primary_color"
        case iconImageUrl = "icon_image_url"
        case bannerImageUrl = "banner_image_url"
    }
    
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
        
        
        iconImageUrl = Thing.getUrl(data: data, key: "icon_img")
        bannerImageUrl = Thing.getUrl(data: data, key: "banner_background_image")
        
        super.init(id: id, name: name, kind: kind, data: data)
    }
    
    required init(entity: SubredditEntity) {
        
        displayName = entity.displayName!
        displayNamePrefixed = entity.displayNamePrefixed!
        subredditName = entity.name!
        subredditId = entity.id!
        over18 = entity.over18
        primaryColor = entity.primaryColor!
        iconImageUrl = entity.iconImageUrl
        bannerImageUrl = entity.bannerImageUrl
        
        super.init(id: entity.thingId, name: entity.thingName, kind: entity.kind!, data: [:])
        
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    /*required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        displayName = try values.decode(String.self, forKey: .displayName)
        displayNamePrefixed = try values.decode(String.self, forKey: .displayNamePrefixed)
        subredditName = try values.decode(String.self, forKey: .subredditName)
        subredditId = try values.decode(String.self, forKey: .subredditId)
        over18 = try values.decode(Bool.self, forKey: .over18)
        primaryColor = try values.decode(String.self, forKey: .primaryColor)
        iconImageUrl = try values.decode(URL.self, forKey: .iconImageUrl)
        bannerImageUrl = try values.decode(URL.self, forKey: .bannerImageUrl)

        try super.init(from: decoder)
    }*/
    
    
    
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

extension Subreddit {
    
    func createEntity(context: NSManagedObjectContext) {
        
        let entity = SubredditEntity(context: context)
        
        entity.id = subredditId
        entity.name = subredditName
        entity.displayName = displayName
        entity.displayNamePrefixed = displayNamePrefixed
        entity.over18 = over18
        entity.primaryColor = primaryColor
        entity.iconImageUrl = iconImageUrl
        entity.bannerImageUrl = bannerImageUrl
        entity.thingId = thingId
        entity.thingName = name
        entity.kind = kind
        
    }
    
    
    
}
