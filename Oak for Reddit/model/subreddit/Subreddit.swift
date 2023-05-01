//
//  Subreddit.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import Foundation
import CoreData

@objc(Subreddit)
public class Subreddit: Thing {
    
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
    
    @NSManaged private(set) var displayName: String
    @NSManaged private(set) var displayNamePrefixed: String
    //let subredditName: String
    //let subredditId: String
    @NSManaged private(set) var over18: Bool
    @NSManaged private(set) var primaryColor: String
    @NSManaged private(set) var iconImageUrl: URL?
    @NSManaged private(set) var bannerImageUrl: URL?
    
    required init(id: String, name: String, kind: String, data: [String : Any]) {
        
        let moc = PersistenceController.shared.container.viewContext
        guard let entityDesc = NSEntityDescription.entity(forEntityName: "Subreddit", in: moc)
        else {
            fatalError("Thing entity not found!")
        }
        
        super.init(entityDecription: entityDesc, id: id, name: name, kind: kind, data: data)
        
        displayName = data["display_name"] as! String
        displayNamePrefixed = data["display_name_prefixed"] as! String
        //subredditName = data["name"] as! String
        //subredditId = data["id"] as! String
        over18 = (data["over18"] as? Int ?? 0) != 0
        
        if let colorHex = data["primary_color"] as? String, !colorHex.isEmpty{
            primaryColor = colorHex
        }
        else {
            primaryColor = "#33A8FF"
        }
        
        
        iconImageUrl = Thing.getUrl(data: data, key: "icon_img")
        bannerImageUrl = Thing.getUrl(data: data, key: "banner_background_image")
        
        //super.init(id: id, name: name, kind: kind, data: data)
    }
    
    required init(entity: SubredditEntity) {
        
        let moc = PersistenceController.shared.container.viewContext
        guard let entityDesc = NSEntityDescription.entity(forEntityName: "Subreddit", in: moc)
        else {
            fatalError("Thing entity not found!")
        }
        
        super.init(entityDecription: entityDesc, id: entity.thingId!, name: entity.thingName!, kind: entity.kind!, data: [:])
        
        displayName = entity.displayName!
        displayNamePrefixed = entity.displayNamePrefixed!
        //subredditName = entity.name!
        //subredditId = entity.id!
        over18 = entity.over18
        primaryColor = entity.primaryColor!
        iconImageUrl = entity.iconImageUrl
        bannerImageUrl = entity.bannerImageUrl
        
        //super.init(id: entity.thingId!, name: entity.thingName!, kind: entity.kind!, data: [:])
        
    }
    
    required init(entityDecription: NSEntityDescription, id: String, name: String, kind: String, data: [String : Any]) {
        fatalError("init(entityDecription:id:name:kind:data:) has not been implemented")
    }
    
    required init(entity: NSEntityDescription, insertInto: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: insertInto)
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
        return Subreddit(id: "", name: "", kind: "", data: data)
    }()
    
}

extension Subreddit {
    
    func createEntity(context: NSManagedObjectContext) {
        
        let entity = SubredditEntity(context: context)
        
        //entity.id = subredditId
        //entity.name = subredditName
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
