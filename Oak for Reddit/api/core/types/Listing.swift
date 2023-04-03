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
    
    init(before: String? = nil, after: String? = nil, children: [T]){
        self.before = before
        self.after = after
        self.children = children
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
        
        let children: [T] = childrenArray.map { child in
            let childDict = child as! [String : Any]        // TODO: gestire caso kind = more
            return Thing.build(from: childDict)
        }
        
        return Listing<T>(before: before, after: after, children: children)
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
