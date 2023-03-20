//
//  SubredditApi.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import Foundation

enum SubredditListingOrder: Hashable{
    case DEFAULT, POPULAR, NEW
}

class SubrettitApi: ObservableObject {
    
    private let redditApi: RedditApi
    
    private let apiPath = "/subreddits/default"
    private let apiMethod = "GET"
    private let apiScope = "read"
    
    @Published var isUpdating = false
    var subreddits: Listing<Subreddit> {
        get {
            switch order {
            case .DEFAULT:
                return defaultSubreddits
            case .POPULAR:
                return popularSubreddits
            case .NEW:
                return newSubreddits
            }
        }
        set {
            switch order {
            case .DEFAULT:
                defaultSubreddits = newValue
            case .POPULAR:
                popularSubreddits = newValue
            case .NEW:
                newSubreddits = newValue
            }
        }
    }
    
    private var defaultSubreddits: Listing<Subreddit> = Listing.empty()
    private var popularSubreddits: Listing<Subreddit> = Listing.empty()
    private var newSubreddits: Listing<Subreddit> = Listing.empty()
    
    private let defaultEndpoint = ApiEndpoint(scope: "read", path: "/subreddits/default", method: "GET", parameters: [:])
    private let popularEndpoint = ApiEndpoint(scope: "read", path: "/subreddits/popular", method: "GET", parameters: [:])
    private let newEndpoint = ApiEndpoint(scope: "read", path: "/subreddits/new", method: "GET", parameters: [:])
    
    @Published public var order: SubredditListingOrder = .DEFAULT
    
    init(redditApi: RedditApi){
        self.redditApi = redditApi
    }
    
    private func fetch(parameters: [String : Any], order: SubredditListingOrder, onSuccess: @escaping (Listing<Subreddit>) -> Void) {
        if(isUpdating){
            return
        }
        
        isUpdating = true
        
        let endpoint: ApiEndpoint = {
            switch order {
            case .DEFAULT:
                return defaultEndpoint.withParameters(parameters)
            case .POPULAR:
                return popularEndpoint.withParameters(parameters)
            case .NEW:
                return newEndpoint.withParameters(parameters)
            }
        }()
        
        redditApi.callApi(endpoint: endpoint) { result in
            let newSubreddits: Listing<Subreddit> = Listing.build(from: result)
            onSuccess(newSubreddits)
            self.isUpdating = false
        }
    }
    
    func load(){
        
        let parameters = ["limit": 10]
        
        fetch(parameters: parameters, order: order) { newSubreddits in
            self.subreddits = newSubreddits
        }
    }
    
    func loadMore() {
        
        let parameters: [String : Any] = ["limit": 10,
                                          "after": subreddits.after ?? "",
                                          "count": subreddits.count]
        
        fetch(parameters: parameters, order: order) { newSubreddits in
            self.subreddits = self.subreddits ++ newSubreddits
        }
        
    }
    
    
    
}
