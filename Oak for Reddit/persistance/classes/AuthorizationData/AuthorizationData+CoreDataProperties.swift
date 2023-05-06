//
//  AuthorizationData+CoreDataProperties.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/04/23.
//
//

import Foundation
import CoreData


extension AuthorizationData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuthorizationData> {
        return NSFetchRequest<AuthorizationData>(entityName: "AuthorizationData")
    }
    
    convenience init(moc: NSManagedObjectContext, accessToken: String, tokenType: String, expiresIn: Int64, scope: String, refreshToken: String?, expireDate: Date) {
        
        self.init(context: moc)
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.scope = scope
        self.refreshToken = refreshToken
        self.expireDate = expireDate
    }

    @NSManaged public var accessToken: String
    @NSManaged public var tokenType: String
    @NSManaged public var expiresIn: Int64
    @NSManaged public var scope: String
    @NSManaged public var refreshToken: String?
    @NSManaged public var expireDate: Date
    @NSManaged public var account: Account?
    
    
    var scopes: [Scope] {
        
        if scope == "*" {
            return Scope.allCases
        }
        
        let scopesRaw = scope.split(separator: " ")
        return scopesRaw.compactMap { scopeRaw in
            Scope(rawValue: String(scopeRaw))
        }
    }
    
    
}

extension AuthorizationData : Identifiable {

}
