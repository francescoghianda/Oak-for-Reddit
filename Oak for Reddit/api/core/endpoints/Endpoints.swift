//
//  Endpoint.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 05/04/23.
//

import Foundation

enum Scope: String, CaseIterable {
    
    case any
    case account
    case creddits
    case edit
    case flair
    case history
    case identity
    case livemanage
    case modconfig
    case modcontributors
    case modflair
    case modlog
    case modmail
    case modnote
    case modothers
    case modposts
    case modself
    case modwiki
    case mysubreddits
    case privatemessages
    case read
    case report
    case save
    case structuredstyles
    case submit
    case subscribe
    case vote
    case wikiedit
    case wikiread
    
}

enum Method: String {
    
    case get
    case post
    case delete
    case put
    case patch
    case head
    case connect
    case options
    case trace
    
}


struct Endpoint {
    typealias ParameterDictionary = Dictionary<String, Any>
    
    private(set) var method: Method
    private(set) var scopes: [Scope]
    private(set) var needsAccount: Bool
    private(set) var path: String
    private(set) var parameters: ParameterDictionary
    
}

struct TypedEndpoint<T> {
    
    private(set) var endpoint: Endpoint
    private(set) var parser: ApiFetcher.Parser<T>
    
}

extension Endpoint {
    
    static func buildParameters(_ dictionary: [String : Any?]) -> ParameterDictionary {
        
        dictionary.reduce(into: [:]) { (result: inout [String : Any], tuple: (key: String, value: Any?)) in
            
            if let value = tuple.value {
                result[tuple.key] = value
            }
        }
        
    }
    
}





