//
//  ListingEntity+CoreDataProperties.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/04/23.
//
//

import Foundation
import CoreData


extension ListingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ListingEntity> {
        return NSFetchRequest<ListingEntity>(entityName: "ListingEntity")
    }

    @NSManaged public var after: String?
    @NSManaged public var before: String?
    @NSManaged public var children: NSSet?

}

// MARK: Generated accessors for children
extension ListingEntity {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: ThingEntity)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: ThingEntity)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}

extension ListingEntity : Identifiable {

}
