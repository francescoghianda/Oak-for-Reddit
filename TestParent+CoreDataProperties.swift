//
//  TestParent+CoreDataProperties.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 30/04/23.
//
//

import Foundation
import CoreData


extension TestParent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestParent> {
        return NSFetchRequest<TestParent>(entityName: "TestParent")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?

}

extension TestParent : Identifiable {

}
