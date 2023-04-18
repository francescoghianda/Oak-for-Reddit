//
//  SubredditApi.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import Foundation

enum SubredditListingOrder: String, Hashable, CaseIterable, Identifiable, Equatable{
    case normal = "default", popular, new
        
    var id: String {
        return self.rawValue
    }
}

class SubrettitListModel: ObservableObject {
        
    private let api: RedditApi = RedditApi.shared
    
    private var saved: Listing<Subreddit> = Listing.empty()
    @Published var subreddits: Listing<Subreddit> = Listing.empty()
    
    func save() {
        saved = subreddits
        subreddits = Listing.empty()
    }
    
    func restore() {
        subreddits = saved
    }
    
    func isEmpty() -> Bool {
        return saved.isEmpty && subreddits.isEmpty
    }
    
    func search(sort: SubredditSearchSort, query: String) async {
        
        do {
            subreddits = try await api.fetchListing(.subredditSearch(sort: sort, query: query))
            
        }
        catch {
            print("Error searching subreddits: \(error)")
        }
        
    }
    
    func load(order: SubredditListingOrder = .normal) async{
                
        do {
            subreddits = try await api.fetchListing(.subredditListing(order: order))
        }
        catch{
            print("Error loanding subreddits: \(error)")
        }
    }
    
    func loadMore(order: SubredditListingOrder = .normal) async {
        
        do {
            self.subreddits += try await api.fetchListing(.subredditListing(order: order, after: self.subreddits.after ?? "", count: self.subreddits.count))
        }
        catch{
            print("Error loanding subreddits: \(error)")
        }
    }
    
    
}
