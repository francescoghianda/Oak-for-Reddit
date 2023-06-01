//
//  SubredditApi.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import Foundation

class SubrettitListModel: ObservableObject {
    
    private let service: SubredditService
    private var saved: Listing<Subreddit> = Listing.empty()
    @Published var subreddits: Listing<Subreddit> = Listing.empty()
    @Published private(set) var loading: Bool = false
    @Published private(set) var loadingMore: Bool = false
    @Published private(set) var error: FetchError? = nil
    @Published private(set) var errorLoadingMore: Error? = nil
    @Published private(set) var uuid: UUID = UUID()
    
    init(service: SubredditService = NetworkSubredditService()) {
        self.service = service
    }
    
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
    
    
    func search(sort: SubredditSearchSort, query: String, completion: ((_ results: Listing<Subreddit>?) -> Void)? = nil) {
        
        if loading {
            return
        }
        
        loading = true
        error = nil
        
        Task {
            do {
                let subreddits: Listing<Subreddit> = try await service.search(sort: sort, query: query)
                
                Task { @MainActor [weak self] in
                    self?.subreddits = subreddits
                    self?.loading = false
                    completion?(subreddits)
                }
                
            }
            catch let error as FetchError {
                Task { @MainActor [weak self] in
                    self?.error = error
                    self?.loading = false
                    completion?(nil)
                }
            }
        }
        
    }
    
    func load(order: SubredditListingOrder = .normal, completion: ((_ subreddits: Listing<Subreddit>?) -> Void)? = nil){
             
        if loading {
            return
        }
        
        loading = true
        error = nil
        
        Task {
            do {
                let subreddits: Listing<Subreddit> = try await service.fetch(order: order)
                
                Task { @MainActor [weak self] in
                    self?.subreddits = subreddits
                    self?.loading = false
                    self?.uuid = UUID()
                    completion?(subreddits)
                }
            }
            catch let error as FetchError  {
                
                Task { @MainActor [weak self] in
                    self?.error = error
                    self?.loading = false
                    completion?(nil)
                }
            }
        }
    }
    
    func loadMore(order: SubredditListingOrder = .normal, completion: ((_ newSubreddits: Listing<Subreddit>?) -> Void)? = nil) {
        
        if loadingMore || !subreddits.hasThingsAfter  {
            completion?(nil)
            return
        }
        
        loadingMore = true
        errorLoadingMore = nil
        
        Task {
            
            do {
                let subreddits: Listing<Subreddit> = try await service.fetchMore(order: order, after: subreddits.after ?? "", count: subreddits.count)
                
                Task { @MainActor [weak self] in
                    self?.subreddits += subreddits
                    self?.loadingMore = false
                    completion?(subreddits)
                }
                
            }
            catch{
                Task { @MainActor [weak self] in
                    self?.errorLoadingMore = error
                    self?.loadingMore = false
                    completion?(nil)
                }
            }
            
        }
    }
    
    
}
