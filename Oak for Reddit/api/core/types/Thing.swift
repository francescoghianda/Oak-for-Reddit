//
//  Thing.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 20/03/23.
//

import Foundation
import CoreData

protocol Votable {
    var ups: Int { get }
    var downs: Int { get }
    var likes: Bool? { get }
    
}

protocol Created {
    var created: Date { get }
    var createdUtc: Date { get }
}

protocol ThingFactory{
    associatedtype T
    func build<T: Thing>(from: [String : Any]) -> T
}

enum ThingKind: String {
    case comment = "t1", account = "t2", link = "t3", message = "t4", subreddit = "t5", award = "t6" // t1, t2, t3, t4, t5, t6
}

class Thing: Identifiable, Equatable, ObservableObject {
    
    
    /// Return the name of the Thing (eg. "t3_15bfi0")
    var id: String {
        return name
    }
        
    /// The id of the Thing (eg. "15bfi0")
    let thingId: String
    
    /// The id prefixed with the type of the Thing (eg. "t3_15bfi0")
    let name: String
    
    let kind: String
        
    required init(id: String, name: String, kind: String, data: [String : Any]){
        self.thingId = id
        self.name = name
        self.kind = kind
    }
    
    public static func build<T: Thing>(from: [String : Any], fromListing: Bool = true) -> T { // TODO togliere fromListing e recuperare id e name sempre da data
        
        let data = from["data"] as! [String : Any]
        let kind = from["kind"] as! String
        
        let source = fromListing ? data : from
        
        let id = source["id"] as! String
        let name = source["name"] as! String
        
        return T(id: id, name: name, kind: kind, data: data)
    }
    
    static func == (left: Thing, right: Thing) -> Bool {
        return left.name == right.name
    }
}
