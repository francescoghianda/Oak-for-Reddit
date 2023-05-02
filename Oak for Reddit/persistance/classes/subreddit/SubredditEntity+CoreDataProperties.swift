//
//  SubredditEntity+CoreDataProperties.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 01/05/23.
//
//

import Foundation
import CoreData


extension SubredditEntity: SubredditProtocol {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubredditEntity> {
        return NSFetchRequest<SubredditEntity>(entityName: "SubredditEntity")
    }

    public var id: String {
        return name
    }
    
    @NSManaged public var savingDate: Date
    
    @NSManaged public var bannerImageUrl: URL?
    @NSManaged public var displayName: String
    @NSManaged public var displayNamePrefixed: String
    @NSManaged public var iconImageUrl: URL?
    @NSManaged public var kind: String
    @NSManaged public var over18: Bool
    @NSManaged public var primaryColor: String
    @NSManaged public var thingId: String
    @NSManaged public var name: String

}

extension SubredditEntity : Identifiable {

}
