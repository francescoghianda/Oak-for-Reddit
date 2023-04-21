//
//  Thing.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 20/03/23.
//

import Foundation

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

class Thing: Identifiable, Equatable {
    
    
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
    
    public static func build<T: Thing>(from: [String : Any], fromListing: Bool = false) -> T {
        
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

extension Thing {
    
    static func get<T>(_ key: String, from data: [String : Any], defaultValue: T) -> T {
        data[key] as? T ?? defaultValue
    }
    
    static func get<T>(_ key: String, from data: [String : Any]) -> T {
        data[key] as! T
    }
    
    static func getBool(_ key: String, from data: [String : Any]) -> Bool {
        return get(key, from: data) != 0
    }
    
    static func getBool(_ key: String, from data: [String : Any]) -> Bool? {
        let val = data[key] as? Int
        return val != nil ? val! != 0 : nil
    }
    
    static func getUrl(data: [String : Any], key: String) -> URL? {
        
        if let path = data[key] as? String {
            return URL(string: path)
        }
        return nil
    }
    
    static func getHtmlEcodedString(data: [String : Any], key: String, encoding: String.Encoding = .utf16) -> String? {
        
        let encodedString = data[key] as? String
        
        if let data = encodedString?.data(using: encoding) {
            do {
                let attrStr = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
                return attrStr.string
            }
            catch {
                return nil
            }
        }
        
        return nil
    }
    
    static func extractMedia(data: [String : Any], key: String) -> Media? {
        
        if let data = data[key] as? [String : Any] {
            return Media.build(from: data)
        }
        
        return nil
        
    }
}
