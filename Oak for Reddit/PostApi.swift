//
//  PostApi.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 21/03/23.
//

import Foundation
import SwiftUI

enum TimeRange: String, CaseIterable, Identifiable{
    case hour = "Hour", day = "Day", week = "Week", month = "Month", year = "Year", all = "All"
    
    var id: String {
        return self.rawValue
    }
}

enum PostListingOrder: Hashable, CaseIterable, Identifiable, Equatable{
    case best, hot, new, rising
    case top(range: TimeRange), controversial(range: TimeRange)
    
    var id: String {
        switch self {
        case .best:
            return "best"
        case .hot:
            return "hot"
        case .new:
            return "new"
        case .rising:
            return "rising"
        case .top:
            return "top"
        case .controversial:
            return "controversial"
        }
    }
    
    static var allCases: [PostListingOrder] {
        return [.best, .hot, .new, .rising, .top(range: .hour), .controversial(range: .hour)]
    }
}

class PostApi: ObservableObject {
    
    private let api: RedditApi = RedditApi.shared
    
    let subreddit: Subreddit?
    
    private let bestEndpoint = ApiEndpoint(scope: "read", path: "/best", method: "GET", parameters: [:])
    private let hotEndpoint = ApiEndpoint(scope: "read", path: "/hot", method: "GET", parameters: [:])
    private let newEndpoint = ApiEndpoint(scope: "read", path: "/new", method: "GET", parameters: [:])
    private let risingEndpoint = ApiEndpoint(scope: "read", path: "/rising", method: "GET", parameters: [:])
    private let topEndpoint = ApiEndpoint(scope: "read", path: "/top", method: "GET", parameters: [:])
    private let controversialEndpoint = ApiEndpoint(scope: "read", path: "/controversial", method: "GET", parameters: [:])
    
    @Published var posts: Listing<Post>? = nil
    
    init(subreddit: Subreddit? = nil){
        self.subreddit = subreddit
    }
    
    private func subredditPrexit() -> String {
        if let subreddit = self.subreddit {
            return "/" + subreddit.displayNamePrefixed
        }
        
        return ""
    }
    
    private func fetch(parameters: [String : Any], order: PostListingOrder) async throws -> Listing<Post> {
        
        let endpoint: ApiEndpoint = { () -> ApiEndpoint in
            switch order {
            case .best:
                return bestEndpoint.withParameters(parameters)
            case .hot:
                return hotEndpoint.withParameters(parameters).addParameter(key: "g", value: "GLOBAL")
            case .new:
                return newEndpoint.withParameters(parameters)
            case .rising:
                return risingEndpoint.withParameters(parameters)
            case .top(let range):
                return topEndpoint.withParameters(parameters).addParameter(key: "t", value: range)
            case .controversial(let range):
                return controversialEndpoint.withParameters(parameters).addParameter(key: "t", value: range)
            }
        }()
        .prefixPath(subredditPrexit())
        
        let result = try await api.callApi(endpoint: endpoint)
        
        return Listing.build(from: result)
    }
    
    
    func load(order: PostListingOrder) async {
        
        let parameters: [String : Any] = [
            "limit": 10
        ]
        
        do {
            let newPosts = try await fetch(parameters: parameters, order: order)
            posts = newPosts
        }
        catch {
            print(error)
        }
    }
    
    func loadMore(order: PostListingOrder) async {
       
        if let posts = self.posts {
            
            let parameters: [String : Any] = [
                "limit": 10,
                "after": posts.after ?? posts.last?.subredditId ?? "",
                "count": posts.count
            ]
            
            do {
                let newPosts = try await fetch(parameters: parameters, order: order)
                self.posts! += newPosts
            }
            catch {
                print(error)
            }
            
        }
        else {
            await self.load(order: order)
        }
       
        

        
        
    }
    
    
    
    
}
