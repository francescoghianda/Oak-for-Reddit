//
//  Subreddit.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import Foundation
import CoreData

protocol SubredditProtocol {
    
    var id: String { get }
    var thingId: String { get }
    var name: String { get }
    var kind: String { get }
    
    var displayName: String { get }
    var displayNamePrefixed: String { get }
    var over18: Bool { get }
    var primaryColor: String { get }
    var iconImageUrl: URL? { get }
    var bannerImageUrl: URL? { get }
    
}

class Subreddit: Thing, SubredditProtocol {
    
    let displayName: String
    let displayNamePrefixed: String
    let over18: Bool
    let primaryColor: String
    let iconImageUrl: URL?
    let bannerImageUrl: URL?
    
    required init(id: String, name: String, kind: String, data: [String : Any]) {
        
        displayName = data["display_name"] as! String
        displayNamePrefixed = data["display_name_prefixed"] as! String
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
        
        displayName = entity.displayName
        displayNamePrefixed = entity.displayNamePrefixed
        over18 = entity.over18
        primaryColor = entity.primaryColor
        iconImageUrl = entity.iconImageUrl
        bannerImageUrl = entity.bannerImageUrl
        
        super.init(id: entity.thingId, name: entity.name, kind: entity.kind, data: [:])
        
    }

}
