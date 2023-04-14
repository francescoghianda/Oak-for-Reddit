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
        
    @Published var subreddits: Listing<Subreddit> = Listing.empty()
    
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
