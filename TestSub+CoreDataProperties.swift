//
//  TestSub+CoreDataProperties.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 30/04/23.
//
//

import Foundation
import CoreData


extension TestSub {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestSub> {
        return NSFetchRequest<TestSub>(entityName: "TestSub")
    }

    @NSManaged public var attr1: String?
    @NSManaged public var attr2: String?
    @NSManaged public var attr3: String?

}
