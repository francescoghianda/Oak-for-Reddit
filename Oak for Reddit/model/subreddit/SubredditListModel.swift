//
//  SubredditApi.swift
//  Oak for Reddit
//
//  Created by Francesco Ghianda on 18/03/23.
//

import Foundation

class SubrettitListModel: ObservableObject {
        
    private let api: ApiFetcher = ApiFetcher.shared
    
    private var saved: Listing<Subreddit> = Listing.empty()
    @Published var subreddits: Listing<Subreddit> = Listing.empty()
    @Published private(set) var loading: Bool = false
    @Published private(set) var loadingMore: Bool = false
    @Published private(set) var error: FetchError? = nil
    @Published private(set) var errorLoadingMore: Error? = nil
    @Published private(set) var uuid: UUID = UUID()
    
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
    
    func search(sort: SubredditSearchSort, query: String) {
        
        if loading {
            return
        }
        
        loading = true
        error = nil
        
        Task {
            do {
                let subreddits: Listing<Subreddit> = try await api.fetchListing(.subredditSearch(sort: sort, query: query))
                
                Task { @MainActor [weak self] in
                    self?.subreddits = subreddits
                    self?.loading = false
                }
                
            }
            catch let error as FetchError {
                Task { @MainActor [weak self] in
                    self?.error = error
                    self?.loading = false
                }
            }
        }
        
    }
    
    func load(order: SubredditListingOrder = .normal){
             
        if loading {
            return
        }
        
        loading = true
        error = nil
        
        Task {
            do {
                let subreddits: Listing<Subreddit> = try await api.fetchListing(.subredditListing(order: order))
                
                Task { @MainActor [weak self] in
                    self?.subreddits = subreddits
                    self?.loading = false
                    self?.uuid = UUID()
                }
            }
            catch let error as FetchError  {
                
                Task { @MainActor [weak self] in
                    self?.error = error
                    self?.loading = false
                }
            }
        }
    }
    
    func loadMore(order: SubredditListingOrder = .normal) {
        
        if loadingMore || !subreddits.hasThingsAfter  {
            return
        }
        
        loadingMore = true
        errorLoadingMore = nil
        
        Task {
            
            do {
                let subreddits: Listing<Subreddit> = try await api.fetchListing(.subredditListing(order: order, after: self.subreddits.after ?? "", count: self.subreddits.count))
                
                Task { @MainActor [weak self] in
                    self?.subreddits += subreddits
                    self?.loadingMore = false
                }
                
            }
            catch{
                Task { @MainActor [weak self] in
                    self?.errorLoadingMore = error
                    self?.loadingMore = false
                }
            }
            
        }
    }
    
    
}
