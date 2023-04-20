//
//  PersistanceController.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 13/04/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
        
    init() {
        container = NSPersistentContainer(name: "Model")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Container load failed: \(error)")
            }
        }
        
        do {
            try loadRequieredData(container: container)
        }
        catch {
            fatalError("Failed to load requiered data: \(error)")
        }
        
    }
    
    private func loadRequieredData(container: NSPersistentContainer) throws {
        
        try loadUserPreferences(container.viewContext)
        
    }
    
    private func loadUserPreferences(_ moc: NSManagedObjectContext) throws {
        
        let request = NSFetchRequest<UserPreferences>(entityName: "UserPreferences")
        let results = try moc.fetch(request)
        
        if let _ = results.first {
            return
        }
        
        let _ = UserPreferences(context: moc)
        try moc.save()
    }
}
