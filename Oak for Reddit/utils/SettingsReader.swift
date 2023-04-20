//
//  SettingsReader.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 19/04/23.
//

import Foundation
import CoreData


struct SettingsReader {
        
    
    static var settings: Settings = {
        
        let moc = PersistenceController.shared.container.viewContext
        let request = NSFetchRequest<Settings>(entityName: "Settings")
        let settings = try? moc.fetch(request)
        
        if let settings = settings?.first {
            return settings
        }
        
        let newSettings = Settings(context: moc)
        try? moc.save()
        return newSettings
        
    }()
    
    static var subredditsPreferredSort: SubredditListingOrder {
        SubredditListingOrder(rawValue: settings.subredditPreferredSort) ?? .normal
    }
    
    static var postsPreferredSort: PostListingOrder {
        PostListingOrder(rawValue: settings.postPreferredSort) ?? .best
    }
    
    static var commentsPreferredSort: CommentsOrder {
        CommentsOrder(rawValue: settings.commentsPreferredOrder) ?? .confidence
    }
    
    
}
