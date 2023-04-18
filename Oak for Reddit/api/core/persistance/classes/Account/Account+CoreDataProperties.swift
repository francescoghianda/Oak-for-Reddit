//
//  Account+CoreDataProperties.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/04/23.
//
//

import Foundation
import CoreData


extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var name: String?
    @NSManaged public var imageUrl: URL?
    @NSManaged public var guest: Bool
    @NSManaged public var authData: AuthorizationData

}

extension Account : Identifiable {

}
