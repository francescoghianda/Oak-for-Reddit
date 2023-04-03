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

enum ThingKind {
    case comment, account, link, message, subreddit, award // t1, t2, t3, t4, t5, t6
}

class Thing: Identifiable, Equatable {
    
    let uuid: String = UUID.init().uuidString
    
    let thingId: String?
    let name: String?
    let kind: String
    let data: [String : Any]
    
    required init(id: String?, name: String?, kind: String, data: [String : Any]){
        self.thingId = id
        self.name = name
        self.kind = kind
        self.data = data
    }
    
    public static func build<T: Thing>(from: [String : Any]) -> T {
        
        let id = from["id"] as? String
        let name = from["name"] as? String
        let kind = from["kind"] as! String
        let data = from["data"] as! [String : Any]
        
        return T(id: id, name: name, kind: kind, data: data)
    }
    
    static func == (left: Thing, right: Thing) -> Bool {
        left.uuid == right.uuid
    }
}

extension Thing {
    static func extractUrl(data: [String : Any], key: String) -> URL? {
        
        if let path = data[key] as? String {
            return URL(string: path)
        }
        return nil
    }
    
    static func extractHtmlEcodedString(data: [String : Any], key: String, encoding: String.Encoding = .utf16) -> String? {
        
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
