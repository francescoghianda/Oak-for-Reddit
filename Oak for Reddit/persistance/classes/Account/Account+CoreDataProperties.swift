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
    @NSManaged public var lastUpdate: Date
    @NSManaged public var avatarUrl: URL?
    @NSManaged public var bannerUrl: URL?
    
    var minutesFromLastUpdate: Int {
        Int(lastUpdate.distance(to: .now) / 60)
    }

}

extension Account : Identifiable {

}

extension Account {
    
    func loadAccountInfos(force: Bool = true) {
        
        if minutesFromLastUpdate < 10 && !force {
            return
        }
        
        Task {
            
            do {
                //let data = try await ApiFetcher.shared.fetchRaw(.accountInfo())
                
                //print(String(decoding: data, as: UTF8.self))
                
                let result = try await ApiFetcher.shared.fetchJsonObject(.accountInfo())
                
                let name = result["name"] as! String
                
                var fullIconUrl = URLComponents(string: result["icon_img"] as! String)!
                fullIconUrl.query = nil
                let imageUrl = fullIconUrl.url!
                let avatarUrl = result.getUrl("snoovatar_img")
                
                let bannerImgUrl: URL? = {
                    
                    guard let subreddit = result["subreddit"] as? [String : Any],
                          let url = subreddit["banner_img"] as? String,
                          var components = URLComponents(string: url)
                    else {
                        return nil
                    }
                    
                    components.query = nil
                    return components.url
                }()
                
                await self.managedObjectContext?.perform {
                    
                    if let avatarUrl = avatarUrl {
                        self.setValue(avatarUrl, forKey: "avatarUrl")
                    }
                    
                    if let bannerUrl = bannerImgUrl {
                        self.setValue(bannerUrl, forKey: "bannerUrl")
                    }
                    
                    self.setValuesForKeys([
                        "name": name,
                        "imageUrl": imageUrl,
                        "guest": false,
                        "lastUpdate": Date.now
                    ])
                    
                    try? self.managedObjectContext?.save()
                    
                }
                
                
               
            }
            catch {
                print(error)
            }
            
        }
        
    }
    
}
