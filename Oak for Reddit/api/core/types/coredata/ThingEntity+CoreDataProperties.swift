//
//  ThingEntity+CoreDataProperties.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/04/23.
//
//

import Foundation
import CoreData


extension ThingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ThingEntity> {
        return NSFetchRequest<ThingEntity>(entityName: "ThingEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var kind: String?
    @NSManaged public var data: [String : Any]?

}

extension ThingEntity : Identifiable {

}
