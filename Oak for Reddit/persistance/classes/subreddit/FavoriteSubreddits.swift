//
//  FavoriteSubreddits.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 01/05/23.
//

import Foundation
import CoreData


class FavoriteSubreddits {
    
    private static var moc: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }
    
    
    static func add(_ subreddit: SubredditProtocol) {
        
        insert(subreddit, into: moc)
        
        if moc.hasChanges {
            try? moc.save()
        }
        
    }
    
    static func remove(_ entity: SubredditEntity) {
        
        moc.delete(entity)
        
        if moc.hasChanges {
            try? moc.save()
        }
        
    }
    
    
    private static func insert(_ subreddit: SubredditProtocol, into context: NSManagedObjectContext) {
        
        let entity = SubredditEntity(context: context)
        
        entity.savingDate = .now
        
        entity.displayName = subreddit.displayName
        entity.displayNamePrefixed = subreddit.displayNamePrefixed
        entity.over18 = subreddit.over18
        entity.primaryColor = subreddit.primaryColor
        entity.iconImageUrl = subreddit.iconImageUrl
        entity.bannerImageUrl = subreddit.bannerImageUrl
        entity.thingId = subreddit.thingId
        entity.name = subreddit.name
        entity.kind = subreddit.kind
        
    }
    
}
