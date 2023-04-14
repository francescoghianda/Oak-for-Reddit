//
//  Listing.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 20/03/23.
//

import Foundation


infix operator ++ : AdditionPrecedence
infix operator += : AdditionPrecedence
final class Listing<T: Thing>: Sequence, RandomAccessCollection, Equatable {
    typealias BaseCollection = [T]
    
    typealias Element = T
    typealias Index = BaseCollection.Index
    
    let before: String?
    let after: String?
    let children: [T]
    let more: More?
    
    init(before: String? = nil, after: String? = nil, children: [T], more: More? = nil){
        self.before = before
        self.after = after
        self.children = children
        self.more = more
    }
    
    var startIndex: Int {
        children.startIndex
    }
    var endIndex: Int {
        children.endIndex
    }
    
    func index(before i: Int) -> Int {
        children.index(before: i)
    }
    
    func index(after i: Int) -> Int {
        children.index(after: i)
    }
    
    subscript(position: Index) -> T {
        children[position]
    }
    
    static func ++<T: Thing>(left: Listing<T>, right: Listing<T>) -> Listing<T> {
        let children = left.children + right.children
        return Listing<T>(before: left.before, after: right.after, children: children)
    }
    
    static func +=<T: Thing>(left: inout Listing<T>, right: Listing<T>) {
        left = left ++ right
    }
    
    public static func empty<T: Thing>() -> Listing<T> {
        return Listing<T>(before: nil, after: nil, children: [])
    }
    
    func makeIterator() -> Array<T>.Iterator {
        return children.makeIterator()
    }
    
    public static func build<T: Thing>(from: [String : Any]) -> Listing<T>{
        
        let data = from["data"] as! [String : Any]
        
        var before = data["before"] as? String
        var after = data["after"] as? String
        
        if(before != nil && before! == "<null>"){
            before = nil
        }
        
        if(after != nil && after! == "<null>"){
            after = nil
        }
        
        let childrenArray: NSArray = data["children"] as! NSArray
        
        var more: More = More.empty()
        
        let children: [T] = childrenArray.compactMap { child in
            let childDict = child as! [String : Any]        
            
            if childDict["kind"] as! String == "more"{
                let moreData = childDict["data"] as! [String : Any]
                more = More.build(from: moreData)//moreData["children"] as! [String]
                return nil
            }
            
            return Thing.build(from: childDict)
        }
        
        
        return Listing<T>(before: before, after: after, children: children, more: more)
    }
    
    static func == (lhs: Listing<T>, rhs: Listing<T>) -> Bool {
        return lhs.children == rhs.children
    }
}

extension Listing{
    
    var hasThingsBefore: Bool {
        !(before?.isEmpty ?? true)
    }
    
    var hasThingsAfter: Bool {
        !(after?.isEmpty ?? true)
    }
}

class More: Sequence, RandomAccessCollection, MutableCollection, Equatable {
    typealias BaseCollection = [String]
    
    typealias Element = String
    typealias Index = BaseCollection.Index
    
    
    var children: [String]
    let name: String?
    let id: String?
    let count: Int?
    let depth: Int?
    let parentId: String?
    
    init(children: [String], name: String?, id: String?, count: Int?, depth: Int?, parentId: String?) {
        self.children = children
        self.name = name
        self.id = id
        self.count = count
        self.depth = depth
        self.parentId = parentId
    }
    
    var startIndex: Int {
        children.startIndex
    }
    var endIndex: Int {
        children.endIndex
    }
    
    func index(before i: Int) -> Int {
        children.index(before: i)
    }
    
    func index(after i: Int) -> Int {
        children.index(after: i)
    }
    
    subscript(position: BaseCollection.Index) -> String {
        get {
            return children[position]
        }
        set(newValue) {
            children[position] = newValue
        }
    }
    
    static func == (lhs: More, rhs: More) -> Bool {
        lhs.children == rhs.children
    }
    
    static func empty() -> More {
        return More(children: [], name: nil, id: nil, count: nil, depth: nil, parentId: nil)
    }
    
    static func build(from data: [String : Any]) -> More {
        
        let children = data["children"] as? [String] ?? []
        let name = data["name"] as? String
        let id = data["id"] as? String
        let count = data["count"] as? Int
        let depth = data["depth"] as? Int
        let parentId = data["parent_id"] as? String
        
        return More(children: children, name: name, id: id, count: count, depth: depth, parentId: parentId)
        
    }
    
}
