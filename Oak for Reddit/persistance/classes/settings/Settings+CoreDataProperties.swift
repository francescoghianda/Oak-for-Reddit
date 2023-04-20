//
//  Settings+CoreDataProperties.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/04/23.
//
//

import Foundation
import CoreData


extension Settings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }

    @NSManaged public var postCardSize: String
    @NSManaged public var postPreferredSort: String
    @NSManaged public var subredditPreferredSort: String
    @NSManaged public var postShowOver18: Bool
    @NSManaged public var subredditShowOver18: Bool
    @NSManaged public var automaticLoadNewPosts: Bool
    @NSManaged public var commentsPreferredOrder: String
    @NSManaged public var commentsViewMode: String

}

extension Settings : Identifiable {
    
}
