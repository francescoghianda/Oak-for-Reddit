//
//  SubredditApi.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import Foundation

enum SubredditListingOrder: String, Hashable, CaseIterable, Identifiable, Equatable{
    case normal, popular, new
        
    var id: String {
        return self.rawValue
    }
}

class SubrettitApi: ObservableObject {
    
    private static let defaultLimit: Int = 10
    
    private let redditApi: RedditApi
    
    //private let apiPath = "/subreddits/default"
    //private let apiMethod = "GET"
    //private let apiScope = "read"
    
    @Published private(set) var defaultSubreddits: Listing<Subreddit> = Listing.empty()
    @Published private(set) var popularSubreddits: Listing<Subreddit> = Listing.empty()
    @Published private(set) var newSubreddits: Listing<Subreddit> = Listing.empty()
    
    private let defaultEndpoint = ApiEndpoint(scope: "read", path: "/subreddits/default", method: "GET", parameters: [:])
    private let popularEndpoint = ApiEndpoint(scope: "read", path: "/subreddits/popular", method: "GET", parameters: [:])
    private let newEndpoint = ApiEndpoint(scope: "read", path: "/subreddits/new", method: "GET", parameters: [:])
    
    //@Published public var order: SubredditListingOrder = .normal
    
    init(redditApi: RedditApi){
        self.redditApi = redditApi
    }
    
    private func fetch(parameters: [String : Any], order: SubredditListingOrder) async throws -> Listing<Subreddit> {
            
        let endpoint: ApiEndpoint = {
            switch order {
            case .normal:
                return defaultEndpoint.withParameters(parameters)
            case .popular:
                return popularEndpoint.withParameters(parameters)
            case .new:
                return newEndpoint.withParameters(parameters)
            }
        }()
        
        let result = try await redditApi.callApi(endpoint: endpoint)
        let newSubreddits: Listing<Subreddit> = Listing.build(from: result)
        return newSubreddits
    }
    
    func load(order: SubredditListingOrder = .normal, limit: Int = SubrettitApi.defaultLimit) async{
        
        let parameters = ["limit": limit]
        
        do {
            let newSubreddits = try await fetch(parameters: parameters, order: order)
            self.setSubreddits(newSubreddits, order: order)
        }
        catch{
            print("Error loanding subreddits: \(error)")
        }
    }
    
    func loadMore(order: SubredditListingOrder = .normal, limit: Int = SubrettitApi.defaultLimit) async {
        
        let subreddits = getListing(order: order)
        
        let parameters: [String : Any] = ["limit": limit,
                                          "after": subreddits.after ?? "",
                                          "count": subreddits.count]
        
        
        do {
            let newSubreddits = try await fetch(parameters: parameters, order: order)
            self.appendSubreddits(newSubreddits, order: order)
        }
        catch{
            print("Error loanding subreddits: \(error)")
        }
    }
    
    func getListing(order: SubredditListingOrder) -> Listing<Subreddit> {
        switch order {
        case .normal:
            return defaultSubreddits
        case .popular:
            return popularSubreddits
        case .new:
            return newSubreddits
        }
    }
    
    private func setSubreddits(_ subreddits: Listing<Subreddit>, order: SubredditListingOrder){
        switch order {
        case .normal:
            defaultSubreddits = subreddits
        case .popular:
            popularSubreddits = subreddits
        case .new:
            newSubreddits = subreddits
        }
    }
    
    private func appendSubreddits(_ subreddits: Listing<Subreddit>, order: SubredditListingOrder){
        switch order {
        case .normal:
            defaultSubreddits += subreddits
        case .popular:
            popularSubreddits += subreddits
        case .new:
            newSubreddits += subreddits
        }
    }
    
    
}
