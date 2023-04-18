//
//  AccountsManager.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/04/23.
//

import Foundation
import CoreData


class AccountsManager {
    
    static let shared: AccountsManager = AccountsManager()
    
    init(){
        
    }
    
    private var request: NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }
    
    private var moc: NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext
    }
    
    var accounts: [Account] {
        return (try? moc.fetch(request)) ?? []
    }
    
    var account: Account? {
        
        let request = request
        
        request.predicate = NSPredicate(format: "guest = %d", false)
        request.fetchLimit = 1
        
        if let account = try? moc.fetch(request).first {
            return account
        }
        
        return guest
        
    }
    
    var guest: Account? {
        
        let request = request
        
        request.predicate = NSPredicate(format: "guest = %d", true)
        request.fetchLimit = 1
        
        return try? moc.fetch(request).first
        
    }
    
    func createGuestAccount(authData: AuthorizationData) -> Account {
        
        let guestAccount = Account(context: moc)
        guestAccount.guest = true
        guestAccount.authData = authData
        
        do {
            try moc.save()
            return guestAccount
        }
        catch {
            print(error.localizedDescription)
            fatalError("Error initilizing guest account")
        }
    }
    
    
}
