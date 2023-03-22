//
//  SubredditApi.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import Foundation

enum SubredditListingOrder: String, Hashable, CaseIterable, Identifiable, Equatable{
    case normal, popular, latest
        
    var id: String {
        return self.rawValue
    }
}

class SubrettitApi: ObservableObject {
    
    private let redditApi: RedditApi
    
    //private let apiPath = "/subreddits/default"
    //private let apiMethod = "GET"
    //private let apiScope = "read"
    
    @Published var isUpdating = false
    var subreddits: Listing<Subreddit> {
        get {
            switch order {
            case .normal:
                return defaultSubreddits
            case .popular:
                return popularSubreddits
            case .latest:
                return newSubreddits
            }
        }
        /*set {
            switch order {
            case .DEFAULT:
                defaultSubreddits = newValue
            case .POPULAR:
                popularSubreddits = newValue
            case .NEW:
                newSubreddits = newValue
            }
        }*/
    }
    
    private var defaultSubreddits: Listing<Subreddit> = Listing.empty()
    private var popularSubreddits: Listing<Subreddit> = Listing.empty()
    private var newSubreddits: Listing<Subreddit> = Listing.empty()
    
    private let defaultEndpoint = ApiEndpoint(scope: "read", path: "/subreddits/default", method: "GET", parameters: [:])
    private let popularEndpoint = ApiEndpoint(scope: "read", path: "/subreddits/popular", method: "GET", parameters: [:])
    private let newEndpoint = ApiEndpoint(scope: "read", path: "/subreddits/new", method: "GET", parameters: [:])
    
    @Published public var order: SubredditListingOrder = .normal
    
    init(redditApi: RedditApi){
        self.redditApi = redditApi
    }
    
    private func fetch(parameters: [String : Any], order: SubredditListingOrder, onSuccess: @escaping (Listing<Subreddit>, SubredditListingOrder) -> Void) {
        if(isUpdating){
            return
        }
        
        isUpdating = true
        
        
        let endpoint: ApiEndpoint = {
            switch order {
            case .normal:
                return defaultEndpoint.withParameters(parameters)
            case .popular:
                return popularEndpoint.withParameters(parameters)
            case .latest:
                return newEndpoint.withParameters(parameters)
            }
        }()
        
        redditApi.callApi(endpoint: endpoint) { result in
            let newSubreddits: Listing<Subreddit> = Listing.build(from: result)
            onSuccess(newSubreddits, order)
            self.isUpdating = false
        }
    }
    
    func load(){
        
        let parameters = ["limit": 10]
        
        fetch(parameters: parameters, order: order) { newSubreddits, order in
            //self.subreddits = newSubreddits
            self.setSubreddits(newSubreddits, order: order)
        }
    }
    
    func loadMore() {
        
        let parameters: [String : Any] = ["limit": 10,
                                          "after": subreddits.after ?? "",
                                          "count": subreddits.count]
        
        fetch(parameters: parameters, order: order) { newSubreddits, order in
            //self.subreddits = self.subreddits ++ newSubreddits
            self.appendSubreddits(newSubreddits, order: order)
        }
        
    }
    
    private func setSubreddits(_ subreddits: Listing<Subreddit>, order: SubredditListingOrder){
        switch order {
        case .normal:
            defaultSubreddits = subreddits
        case .popular:
            popularSubreddits = subreddits
        case .latest:
            newSubreddits = subreddits
        }
    }
    
    private func appendSubreddits(_ subreddits: Listing<Subreddit>, order: SubredditListingOrder){
        switch order {
        case .normal:
            defaultSubreddits += subreddits
        case .popular:
            popularSubreddits += subreddits
        case .latest:
            newSubreddits += subreddits
        }
    }
    
    
}
