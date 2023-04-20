//
//  UserPreferences+CoreDataProperties.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 20/04/23.
//
//

import Foundation
import CoreData


extension UserPreferences {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserPreferences> {
        return NSFetchRequest<UserPreferences>(entityName: "UserPreferences")
    }

    @NSManaged public var loadNewPostsAutomatically: Bool
    @NSManaged public var postPreferredOrderStr: String
    @NSManaged public var showOver18Posts: Bool
    @NSManaged public var blurOver18Images: Bool
    @NSManaged public var showOver18Subreddits: Bool
    @NSManaged public var subredditsPreferredOrder: SubredditListingOrder
    @NSManaged public var postsCardSize: PostCardSize
    @NSManaged public var commentsPreferredOrder: CommentsOrder
    @NSManaged public var commentsViewMode: CommentsViewMode
    
    var postPreferredOrder: PostListingOrder {
        get {
            PostListingOrder(rawValue: postPreferredOrderStr) ?? .best
        }
        set {
            postPreferredOrderStr = newValue.rawValue
        }
    }

}

extension UserPreferences : Identifiable {

}
