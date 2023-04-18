//
//  PostListModel.swift
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

class PostListModel: ObservableObject {
    
    private let api: RedditApi = RedditApi.shared
    
    //let subreddit: Subreddit?
    let subredditNamePrefixed: String
    
    @Published var posts: Listing<Post>? = nil
    
    init(subredditNamePrefixed: String? = nil){
        
        if let subredditNamePrefixed = subredditNamePrefixed {
            self.subredditNamePrefixed = "/\(subredditNamePrefixed)"
        }
        else {
            self.subredditNamePrefixed = ""
        }
    }
    
    
    func load(order: PostListingOrder) async {
        
        do {
            posts = try await api.fetchListing(.postListing(order: order, subredditName: subredditNamePrefixed))
        }
        catch {
            print(error)
        }
    }
    
    func loadMore(order: PostListingOrder) async {
       
        if let posts = self.posts {
            
            let after = posts.after ?? posts.last?.subredditId ?? ""
            
            do {
                self.posts! += try await api.fetchListing(.postListing(order: order, subredditName: subredditNamePrefixed, after: after, count: posts.count))
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
